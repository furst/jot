import JotKit
import SwiftUI

struct SidebarView: View {
    let items: [SidebarItemDefinition]
    @Binding var selectedItemID: String

    var body: some View {
        VStack(spacing: 2) {
            ForEach(items) { item in
                SidebarRow(
                    item: item,
                    isSelected: selectedItemID == item.id
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedItemID = item.id
                }
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .frame(width: 120)
        .background(Color.black.opacity(0.2))
    }
}

struct SidebarRow: View {
    let item: SidebarItemDefinition
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 0) {
            Text(item.label)
                .font(.system(size: 13, weight: isSelected ? .semibold : .regular))
                .foregroundColor(.primary)
                .padding(.leading, 12)

            Spacer()

            KeyboardShortcutHint(label: "", keys: ["\u{2318}\(item.shortcutIndex)"])
                .padding(.trailing, 8)
        }
        .padding(.vertical, 6)
        .background(
            isSelected
                ? RoundedRectangle(cornerRadius: 6)
                    .fill(Color.white.opacity(0.08))
                    .padding(.horizontal, 4)
                : nil
        )
    }
}
