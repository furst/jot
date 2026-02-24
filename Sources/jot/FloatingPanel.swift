import AppKit

final class FloatingPanel: NSPanel {
    private let visualEffectView: NSVisualEffectView
    private let contentContainer: NSView = NSView()

    init() {
        visualEffectView = NSVisualEffectView()

        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 340),
            styleMask: [.borderless],
            backing: .buffered,
            defer: true
        )

        isFloatingPanel = true
        level = .floating
        isMovableByWindowBackground = true
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Rounded clip container as the window's content view
        let container = NSView(frame: contentRect(forFrameRect: frame))
        container.wantsLayer = true
        container.layer?.cornerRadius = 12
        container.layer?.masksToBounds = true
        container.appearance = NSAppearance(named: .darkAqua)
        contentView = container

        // Frosted blur layer
        visualEffectView.material = .hudWindow
        visualEffectView.blendingMode = .behindWindow
        visualEffectView.state = .active
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(visualEffectView)

        // Dark tint over the blur, below content
        let tintView = NSView()
        tintView.wantsLayer = true
        tintView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.35).cgColor
        tintView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(tintView)

        // Content container sits above the tint
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(contentContainer)

        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: container.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            tintView.topAnchor.constraint(equalTo: container.topAnchor),
            tintView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            tintView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentContainer.topAnchor.constraint(equalTo: container.topAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
        ])
    }

    func setContentSwiftUI(_ view: NSView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
        ])
    }

    override var canBecomeKey: Bool { true }

    override func cancelOperation(_ sender: Any?) {
        close()
    }
}
