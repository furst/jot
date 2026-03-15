import Foundation
import SwiftUI

public struct SidebarItemDefinition: Identifiable, Equatable {
    public let id: String
    public let label: String
    public let accentColor: Color
    public let shortcutIndex: Int

    public init(id: String, label: String, accentColor: Color, shortcutIndex: Int) {
        self.id = id
        self.label = label
        self.accentColor = accentColor
        self.shortcutIndex = shortcutIndex
    }

    public static let jot = SidebarItemDefinition(
        id: "jot", label: "Jot", accentColor: .yellow, shortcutIndex: 1
    )

    public static let daily = SidebarItemDefinition(
        id: "daily", label: "Daily", accentColor: .blue, shortcutIndex: 2
    )

    public static let builtIn: [SidebarItemDefinition] = [.jot, .daily]
}
