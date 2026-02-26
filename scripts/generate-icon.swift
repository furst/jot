#!/usr/bin/env swift
import AppKit

// Required icon sizes for macOS .icns
let iconSizes: [(String, Int)] = [
    ("icon_16x16", 16),
    ("icon_16x16@2x", 32),
    ("icon_32x32", 32),
    ("icon_32x32@2x", 64),
    ("icon_128x128", 128),
    ("icon_128x128@2x", 256),
    ("icon_256x256", 256),
    ("icon_256x256@2x", 512),
    ("icon_512x512", 512),
    ("icon_512x512@2x", 1024),
]

func renderIcon(pixelSize: Int) -> Data {
    let s = CGFloat(pixelSize)
    let sc = s / 128.0

    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil, pixelsWide: pixelSize, pixelsHigh: pixelSize,
        bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
        colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0
    )!

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)!
    let ctx = NSGraphicsContext.current!.cgContext

    // --- Background: squircle with warm amber gradient ---
    let inset = s * 0.03
    let bgRect = NSRect(x: inset, y: inset, width: s - inset * 2, height: s - inset * 2)
    let cornerRadius = s * 0.22
    let bg = NSBezierPath(roundedRect: bgRect, xRadius: cornerRadius, yRadius: cornerRadius)

    NSGradient(colors: [
        NSColor(calibratedRed: 0.94, green: 0.56, blue: 0.15, alpha: 1.0),
        NSColor(calibratedRed: 1.0, green: 0.78, blue: 0.36, alpha: 1.0),
    ])!.draw(in: bg, angle: 90)

    // Subtle highlight at the top
    let hlRect = bgRect.insetBy(dx: s * 0.04, dy: s * 0.04)
    let hl = NSBezierPath(roundedRect: hlRect, xRadius: cornerRadius * 0.88, yRadius: cornerRadius * 0.88)
    NSGradient(colors: [
        NSColor(calibratedWhite: 1.0, alpha: 0.0),
        NSColor(calibratedWhite: 1.0, alpha: 0.12),
    ])!.draw(in: hl, angle: 90)

    // --- Simplified lightning-pencil shape (matching menu bar icon) ---
    // Draw on an 18-unit grid, then scale and position to fit the icon

    let shapeH: CGFloat = 16.5  // shape spans y 1..17.5
    let gridScale = s * 0.65 / shapeH
    let ox = s * 0.5 - 8.5 * gridScale  // center horizontally (shape ~3..12)
    let oy = s * 0.14                     // top padding

    // Flip Y for top-down drawing
    ctx.saveGState()
    ctx.translateBy(x: 0, y: s)
    ctx.scaleBy(x: 1, y: -1)

    // Apply 15° rotation around center of shape (matching menu bar icon)
    let cx = 8.5 * gridScale + ox
    let cy = 9.25 * gridScale + oy
    ctx.translateBy(x: cx, y: cy)
    ctx.rotate(by: -15 * .pi / 180)  // negative because Y is flipped
    ctx.translateBy(x: -cx, y: -cy)

    func p(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x * gridScale + ox, y: y * gridScale + oy)
    }

    // Shadow behind the shape
    ctx.setShadow(offset: CGSize(width: 1 * sc, height: -3 * sc), blur: 8 * sc,
                  color: CGColor(gray: 0, alpha: 0.3))
    ctx.setFillColor(CGColor(gray: 1, alpha: 1))

    // Lightning bolt body (white)
    ctx.beginPath()
    ctx.move(to: p(12, 1))
    ctx.addLine(to: p(5, 1))
    ctx.addLine(to: p(5, 7.5))
    ctx.addLine(to: p(3, 7.5))
    ctx.addLine(to: p(10, 13))
    ctx.addLine(to: p(10, 9.5))
    ctx.addLine(to: p(12, 9.5))
    ctx.closePath()
    ctx.fillPath()

    // Pencil tip (white base)
    ctx.beginPath()
    ctx.move(to: p(4, 13))
    ctx.addLine(to: p(10, 13))
    ctx.addLine(to: p(7, 17.5))
    ctx.closePath()
    ctx.fillPath()

    // Disable shadow for details
    ctx.setShadow(offset: .zero, blur: 0)

    // Depth shading on right side of bolt
    ctx.setFillColor(CGColor(gray: 0.88, alpha: 0.5))
    ctx.beginPath()
    ctx.move(to: p(10, 9.5))
    ctx.addLine(to: p(12, 9.5))
    ctx.addLine(to: p(12, 1))
    ctx.addLine(to: p(9, 1))
    ctx.addLine(to: p(9, 7.5))
    ctx.addLine(to: p(10, 7.5))
    ctx.closePath()
    ctx.fillPath()

    // Wood section of pencil tip
    ctx.setFillColor(CGColor(srgbRed: 0.87, green: 0.69, blue: 0.44, alpha: 1.0))
    ctx.beginPath()
    ctx.move(to: p(5, 13))
    ctx.addLine(to: p(9, 13))
    ctx.addLine(to: p(7, 16))
    ctx.closePath()
    ctx.fillPath()

    // Graphite point
    ctx.setFillColor(CGColor(srgbRed: 0.18, green: 0.18, blue: 0.18, alpha: 1.0))
    ctx.beginPath()
    ctx.move(to: p(6, 15.5))
    ctx.addLine(to: p(8, 15.5))
    ctx.addLine(to: p(7, 17.5))
    ctx.closePath()
    ctx.fillPath()

    ctx.restoreGState()

    NSGraphicsContext.restoreGraphicsState()
    return rep.representation(using: .png, properties: [:])!
}

// --- Generate iconset and convert to .icns ---
let scriptDir = URL(fileURLWithPath: CommandLine.arguments[0]).deletingLastPathComponent()
let projectDir = scriptDir.deletingLastPathComponent()
let iconsetDir = projectDir.appendingPathComponent(".build/AppIcon.iconset")
let icnsPath = projectDir.appendingPathComponent(".build/AppIcon.icns")

try FileManager.default.createDirectory(at: iconsetDir, withIntermediateDirectories: true)

for (name, size) in iconSizes {
    let png = renderIcon(pixelSize: size)
    try png.write(to: iconsetDir.appendingPathComponent("\(name).png"))
    print("  \(name).png (\(size)x\(size))")
}

let proc = Process()
proc.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
proc.arguments = ["-c", "icns", iconsetDir.path, "-o", icnsPath.path]
try proc.run()
proc.waitUntilExit()

guard proc.terminationStatus == 0 else {
    fputs("iconutil failed with status \(proc.terminationStatus)\n", stderr)
    exit(1)
}

print("Created \(icnsPath.path)")
