import JotKit
import SwiftUI

struct MainContentView: View {
    var onSave: (String, String, String) -> Void
    var onCancel: () -> Void

    @State private var selectedItemID = SidebarItemDefinition.jot.id
    @State private var showSidebar = Preferences.showSidebar
    @State private var commandHeld = false

    var body: some View {
        HStack(spacing: 0) {
            if showSidebar {
                SidebarView(
                    items: SidebarItemDefinition.builtIn,
                    selectedItemID: $selectedItemID
                )

                Divider()
                    .overlay(Color.white.opacity(0.1))
            }

            // Content area
            Group {
                switch selectedItemID {
                case SidebarItemDefinition.jot.id:
                    NoteEditorView(onSave: onSave, onCancel: onCancel)
                case SidebarItemDefinition.daily.id:
                    DailyNoteView(onSave: { onCancel() }, onCancel: onCancel)
                default:
                    Text("Unknown view")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .frame(width: showSidebar ? 680 : 560, height: 340)
        .overlay(alignment: .leading) {
            if !showSidebar && commandHeld {
                VStack(spacing: 2) {
                    ForEach(SidebarItemDefinition.builtIn) { item in
                        HStack(spacing: 8) {
                            Text(item.label)
                                .font(.system(size: 12, weight: selectedItemID == item.id ? .semibold : .regular))
                            Spacer()
                            Text("\u{2318}\(item.shortcutIndex)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            selectedItemID == item.id
                                ? RoundedRectangle(cornerRadius: 5).fill(Color.white.opacity(0.1))
                                : nil
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedItemID = item.id
                        }
                    }
                }
                .frame(width: 110)
                .padding(6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.ultraThinMaterial)
                        .shadow(color: .black.opacity(0.3), radius: 8, y: 2)
                )
                .padding(.leading, 8)
                .transition(.opacity.combined(with: .move(edge: .leading)))
            }
        }
        .animation(.easeInOut(duration: 0.15), value: commandHeld)
        .overlay {
            // Hidden buttons for sidebar keyboard shortcuts
            VStack {
                ForEach(SidebarItemDefinition.builtIn) { item in
                    Button("") {
                        selectedItemID = item.id
                    }
                    .keyboardShortcut(
                        KeyEquivalent(Character("\(item.shortcutIndex)")),
                        modifiers: .command
                    )
                }
            }
            .frame(width: 0, height: 0)
            .opacity(0)
        }
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { event in
                commandHeld = event.modifierFlags.contains(.command)
                return event
            }
        }
    }
}
