import AppKit

enum MenuBarIcon {
    /// Creates a pencil-lightning bolt menu bar icon.
    /// Simplified silhouette: lightning bolt body + pencil tip, tilted slightly.
    /// Returned as a template image so macOS auto-tints for light/dark mode.
    static func create() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: true) { _ in
            NSColor.black.setFill()

            let shape = NSBezierPath()

            // Lightning bolt body
            shape.move(to: NSPoint(x: 12, y: 1))
            shape.line(to: NSPoint(x: 5, y: 1))
            shape.line(to: NSPoint(x: 5, y: 7.5))
            shape.line(to: NSPoint(x: 3, y: 7.5))
            shape.line(to: NSPoint(x: 10, y: 13))
            shape.line(to: NSPoint(x: 10, y: 9.5))
            shape.line(to: NSPoint(x: 12, y: 9.5))
            shape.close()

            // Pencil tip
            shape.move(to: NSPoint(x: 4, y: 13))
            shape.line(to: NSPoint(x: 10, y: 13))
            shape.line(to: NSPoint(x: 7, y: 17.5))
            shape.close()

            // Rotate ~15° around the center of the shape
            let transform = NSAffineTransform()
            transform.translateX(by: 9, yBy: 9)
            transform.rotate(byDegrees: 15)
            transform.translateX(by: -9, yBy: -9)
            shape.transform(using: transform as AffineTransform)

            shape.fill()

            return true
        }
        image.isTemplate = true
        return image
    }
}
