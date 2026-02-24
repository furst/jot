import SwiftUI

struct NoteEditorView: View {
    var onSave: (String, String, String) -> Void
    var onCancel: () -> Void

    @State private var title = ""
    @State private var tagInput = ""
    @State private var tags: [String] = []
    @State private var noteBody = ""

    private var tagsString: String {
        tags.joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title header
            TextField("Title...", text: $title)
                .textFieldStyle(.plain)
                .font(.system(size: 18, weight: .semibold))
                .accessibilityLabel("Note title")
                .accessibilityHint("Optional title for the note")
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            Divider()
                .overlay(Color.white.opacity(0.1))

            // Note body
            HighlightedTextEditor(text: $noteBody)
                .accessibilityLabel("Note body")
                .accessibilityHint("Main content of the note")
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            // Tags row
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color.white.opacity(0.1))

                FlowLayout(spacing: 6) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(label: tag) {
                            tags.removeAll { $0 == tag }
                        }
                    }
                    TextField(tags.isEmpty ? "Tags..." : "", text: $tagInput)
                        .textFieldStyle(.plain)
                        .font(.system(size: 12))
                        .frame(minWidth: 80, maxWidth: .infinity)
                        .onChange(of: tagInput) { newValue in
                            if newValue.last == "," || newValue.last == " " {
                                commitTag(newValue)
                            }
                        }
                        .onSubmit { commitTag(tagInput) }
                        .accessibilityLabel("Tags")
                        .accessibilityHint("Type a tag and press comma or space to add it")
                }
                .padding(.horizontal, 16)
                .frame(height: 36)
            }

            // Bottom bar
            VStack(spacing: 0) {
                Divider()
                    .overlay(Color.white.opacity(0.1))

                HStack(spacing: 4) {
                    KeyboardShortcutHint(label: "Save", keys: ["⌘", "↵"])

                    Spacer()

                    KeyboardShortcutHint(label: "Cancel", keys: ["esc"])
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.2))
            }
        }
        .frame(width: 560, height: 340)
        .overlay {
            // Hidden buttons to register keyboard shortcuts
            VStack {
                Button("") {
                    onCancel()
                }
                .keyboardShortcut(.cancelAction)
                Button("") {
                    commitTag(tagInput)
                    onSave(title, noteBody, tagsString)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .disabled(noteBody.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .frame(width: 0, height: 0)
            .opacity(0)
        }
    }

    private func commitTag(_ input: String) {
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines.union(.init(charactersIn: ",")))
        if !cleaned.isEmpty && !tags.contains(where: { $0.caseInsensitiveCompare(cleaned) == .orderedSame }) {
            tags.append(cleaned)
        }
        tagInput = ""
    }
}

// MARK: - Keyboard Shortcut Hint

struct KeyboardShortcutHint: View {
    let label: String
    let keys: [String]

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.secondary)
            HStack(spacing: 2) {
                ForEach(keys, id: \.self) { key in
                    Text(key)
                        .font(.system(size: 10, weight: .medium))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(3)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Tag Chip

struct TagChip: View {
    let label: String
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 3) {
            Text(label)
                .font(.system(size: 11))
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Remove \(label)")
            .accessibilityHint("Remove this tag")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(Color.primary.opacity(0.1))
        .cornerRadius(4)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var height: CGFloat = 0
        for (i, row) in rows.enumerated() {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            height += rowHeight + (i > 0 ? spacing : 0)
        }
        return CGSize(width: proposal.width ?? 0, height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let rows = computeRows(proposal: proposal, subviews: subviews)
        var y = bounds.minY
        for row in rows {
            let rowHeight = row.map { $0.sizeThatFits(.unspecified).height }.max() ?? 0
            var x = bounds.minX
            for subview in row {
                let size = subview.sizeThatFits(.unspecified)
                subview.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
                x += size.width + spacing
            }
            y += rowHeight + spacing
        }
    }

    private func computeRows(proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        let maxWidth = proposal.width ?? .infinity
        var rows: [[LayoutSubviews.Element]] = [[]]
        var currentWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentWidth + size.width + spacing > maxWidth && !rows[rows.count - 1].isEmpty {
                rows.append([])
                currentWidth = 0
            }
            rows[rows.count - 1].append(subview)
            currentWidth += size.width + spacing
        }
        return rows
    }
}
