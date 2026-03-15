import JotKit
import SwiftUI

struct DailyNoteView: View {
    var onSave: () -> Void
    var onCancel: () -> Void

    @State private var noteBody = ""

    private var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    var body: some View {
        VStack(spacing: 0) {
            // Date header
            HStack {
                Text(dateString)
                    .font(.system(size: 18, weight: .semibold))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 12)

            Divider()
                .overlay(Color.white.opacity(0.1))

            // Note body
            HighlightedTextEditor(text: $noteBody)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            // Bottom bar
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color.white.opacity(0.1))

                HStack(spacing: 4) {
                    Button {
                        saveNote()
                    } label: {
                        KeyboardShortcutHint(label: "Save", keys: ["\u{2318}", "\u{21A9}"])
                    }
                    .buttonStyle(.plain)
                    .disabled(noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    Spacer()

                    Button {
                        onCancel()
                    } label: {
                        KeyboardShortcutHint(label: "Cancel", keys: ["esc"])
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.2))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            VStack {
                Button("") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                Button("") {
                    saveNote()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .frame(width: 0, height: 0)
            .opacity(0)
        }
        .onAppear {
            do {
                noteBody = try DailyNoteService.load()
            } catch {
                noteBody = ""
            }
        }
    }

    private func saveNote() {
        let trimmed = noteBody.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            try DailyNoteService.save(content: noteBody)
            onSave()
        } catch {
            let alert = NSAlert()
            alert.messageText = "Failed to save daily note"
            alert.informativeText = error.localizedDescription
            alert.alertStyle = .critical
            alert.runModal()
        }
    }
}
