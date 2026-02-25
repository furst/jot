import JotKit
import ServiceManagement
import SwiftUI

// MARK: - General Tab

struct GeneralSettingsView: View {
    @State private var launchAtLogin = SMAppService.mainApp.status == .enabled

    var body: some View {
        Form {
            Section {
                LabeledContent("Launch at Login") {
                    Toggle("", isOn: $launchAtLogin)
                        .labelsHidden()
                        .accessibilityLabel("Launch at Login")
                        .accessibilityHint("Start jot automatically when you log in")
                        .onChange(of: launchAtLogin) { newValue in
                            do {
                                if newValue {
                                    try SMAppService.mainApp.register()
                                } else {
                                    try SMAppService.mainApp.unregister()
                                }
                            } catch {
                                launchAtLogin = !newValue
                            }
                        }
                }
            } header: {
                Text("Startup")
            }

            Section {
                ShortcutRecorder()
                Text("Press Change to record a new shortcut.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Global Shortcut")
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            launchAtLogin = SMAppService.mainApp.status == .enabled
        }
    }
}

// MARK: - Notes Tab

struct NotesSettingsView: View {
    @State private var saveDirectory = Preferences.saveDirectory
    @State private var defaultTag = Preferences.defaultTag

    var body: some View {
        Form {
            Section("Save Location") {
                LabeledContent("Folder") {
                    HStack(spacing: 6) {
                        Image(systemName: "folder.fill")
                            .foregroundStyle(.secondary)
                        Text((saveDirectory as NSString).lastPathComponent)
                            .font(.system(size: 13, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                            .foregroundStyle(.primary)
                            .help(saveDirectory)
                            .accessibilityLabel("Save directory path")
                            .accessibilityHint("File path where notes are saved")

                        Spacer()

                        Button("Browse\u{2026}") {
                            let panel = NSOpenPanel()
                            panel.canChooseDirectories = true
                            panel.canChooseFiles = false
                            panel.canCreateDirectories = true
                            panel.allowsMultipleSelection = false
                            if panel.runModal() == .OK, let url = panel.url {
                                saveDirectory = url.path
                                Preferences.saveDirectory = saveDirectory
                            }
                        }
                        .accessibilityLabel("Browse")
                        .accessibilityHint("Choose a folder for saving notes")
                    }
                }
            }

            Section {
                LabeledContent("Tag") {
                    TextField("e.g. quicknote", text: $defaultTag)
                        .textFieldStyle(.roundedBorder)
                        .accessibilityLabel("Default tag")
                        .accessibilityHint("Tag automatically added to every note")
                        .onChange(of: defaultTag) { newValue in
                            Preferences.defaultTag = newValue
                        }
                }
                Text("Added as YAML frontmatter to new notes. Leave empty for no frontmatter.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Default Tag")
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .fixedSize(horizontal: false, vertical: true)
    }
}

// MARK: - Shortcut Recorder

struct ShortcutRecorder: View {
    @State private var key = Preferences.shortcutKey
    @State private var modifiers = Preferences.shortcutModifiers
    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        HStack {
            if isRecording {
                Text("Press new shortcut\u{2026}")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Color.accentColor, lineWidth: 1.5)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.accentColor.opacity(0.08))
                            )
                    }
            } else {
                Text(displayString)
                    .font(.system(size: 13, design: .monospaced))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.2), lineWidth: 1)
                            .background(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color.primary.opacity(0.04))
                            )
                    }
                    .shadow(color: .black.opacity(0.06), radius: 1, y: 1)
            }

            Spacer()

            Button(isRecording ? "Cancel" : "Change") {
                if isRecording {
                    stopRecording()
                } else {
                    startRecording()
                }
            }
            .accessibilityLabel(isRecording ? "Cancel shortcut recording" : "Change global shortcut")
            .accessibilityHint(isRecording ? "Stop recording a new shortcut" : "Record a new global keyboard shortcut")
        }
        .onDisappear { stopRecording() }
    }

    private var displayString: String {
        let flags = NSEvent.ModifierFlags(rawValue: modifiers)
        var s = ""
        if flags.contains(.control) { s += "⌃" }
        if flags.contains(.option) { s += "⌥" }
        if flags.contains(.shift) { s += "⇧" }
        if flags.contains(.command) { s += "⌘" }
        s += key.uppercased()
        return s
    }

    private func startRecording() {
        isRecording = true
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            // Escape cancels
            if event.keyCode == 53 {
                stopRecording()
                return nil
            }

            let mods = event.modifierFlags.intersection([.command, .shift, .option, .control])
            guard !mods.isEmpty,
                  let chars = event.charactersIgnoringModifiers, !chars.isEmpty else {
                return nil
            }

            key = chars
            modifiers = mods.rawValue
            Preferences.shortcutKey = chars
            Preferences.shortcutModifiers = mods.rawValue
            stopRecording()
            NotificationCenter.default.post(name: .shortcutDidChange, object: nil)
            return nil
        }
    }

    private func stopRecording() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        isRecording = false
    }
}

// MARK: - About Tab

struct AboutSettingsView: View {
    private var version: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "–"
    }

    private var build: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "–"
    }

    private var commit: String? {
        (Bundle.main.infoDictionary?["JotBuildCommit"] as? String).flatMap { $0.isEmpty ? nil : $0 }
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    if let icon = NSImage(named: "AppIcon") {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 80, height: 80)
                    }

                    Text("jot")
                        .font(.title.bold())

                    VStack(spacing: 4) {
                        Text("Version \(version) (\(build))")
                            .font(.callout)
                            .foregroundStyle(.secondary)

                        if let commit {
                            Text(commit.prefix(7))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Link("GitHub Repository",
                         destination: URL(string: "https://github.com/furst/jot")!)
                        .font(.callout)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .formStyle(.grouped)
        .frame(width: 480)
        .fixedSize(horizontal: false, vertical: true)
    }
}
