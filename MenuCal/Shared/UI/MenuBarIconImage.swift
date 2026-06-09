//
//  MenuBarIconImage.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import AppKit

// A calendar-shaped icon with a day number / weekday drawn inside, rendered as a
// template NSImage so it tints with the menu bar. SF Symbols has no day-specific
// calendar glyph, so it's drawn with AppKit and cached (it only changes daily).
@MainActor
enum MenuBarIconImage {
    private static var cache: [String: NSImage] = [:]

    /// Renders the whole menu bar label (icon + text) into a single template image.
    /// `NSStatusItem` renders a SwiftUI `Text` label via its plain string title and
    /// drops inline image attachments, so the icon must be baked into the image.
    static func label(_ segments: [MenuBarSegment], font: NSFont = .systemFont(ofSize: 14)) -> NSImage {
        let spacing: CGFloat = 4
        let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]

        let pieces: [NSImage] = segments.compactMap { segment in
            switch segment.kind {
            case .text(let value):
                return textImage(NSAttributedString(string: value, attributes: attributes))
            case .calendarGlyph(let text):
                return glyph(text)
            case .icon(let systemName):
                return symbol(systemName, pointSize: font.pointSize)
            }
        }

        guard !pieces.isEmpty else {
            return symbol("calendar", pointSize: font.pointSize) ?? NSImage()
        }

        let height = ceil(pieces.map { $0.size.height }.max() ?? font.pointSize)
        let width = ceil(pieces.map { $0.size.width }.reduce(0, +) + spacing * CGFloat(pieces.count - 1))

        let image = NSImage(size: NSSize(width: max(width, 1), height: max(height, 1)), flipped: false) { _ in
            var x: CGFloat = 0
            for piece in pieces {
                let size = piece.size
                let y = ((height - size.height) / 2).rounded()
                piece.draw(in: NSRect(x: x, y: y, width: size.width, height: size.height))
                x += size.width + spacing
            }
            return true
        }
        image.isTemplate = true
        return image
    }

    private static func symbol(_ name: String, pointSize: CGFloat) -> NSImage? {
        let config = NSImage.SymbolConfiguration(pointSize: pointSize, weight: .regular)
        let image = NSImage(systemSymbolName: name, accessibilityDescription: nil)?
            .withSymbolConfiguration(config)
        image?.isTemplate = true
        return image
    }

    private static func textImage(_ attributed: NSAttributedString) -> NSImage {
        let size = NSSize(width: ceil(attributed.size().width), height: ceil(attributed.size().height))
        let image = NSImage(size: NSSize(width: max(size.width, 1), height: max(size.height, 1)), flipped: false) { _ in
            attributed.draw(at: .zero)
            return true
        }
        image.isTemplate = true
        return image
    }

    static func glyph(_ text: String) -> NSImage {
        if let cached = cache[text] { return cached }
        let image = draw(text: text)
        cache[text] = image
        return image
    }

    private static func draw(text: String) -> NSImage {
        let size = NSSize(width: 15, height: 15)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setStroke()

            let body = rect.insetBy(dx: 0.65, dy: 0.65)
            let bodyPath = NSBezierPath(roundedRect: body, xRadius: 3, yRadius: 3)
            bodyPath.lineWidth = 1.3
            bodyPath.stroke()

            let headerY = body.maxY - 3.5
            let divider = NSBezierPath()
            divider.move(to: NSPoint(x: body.minX + 1, y: headerY))
            divider.line(to: NSPoint(x: body.maxX - 1, y: headerY))
            divider.lineWidth = 1.1
            divider.stroke()

            let fontSize: CGFloat = text.count > 1 ? 8.5 : 10
            let attributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: fontSize, weight: .bold),
                .foregroundColor: NSColor.black,
            ]
            let attributed = NSAttributedString(string: text, attributes: attributes)
            let textSize = attributed.size()
            let lower = NSRect(x: body.minX, y: body.minY, width: body.width, height: headerY - body.minY)
            let origin = NSPoint(
                x: lower.midX - textSize.width / 2,
                y: lower.midY - textSize.height / 2
            )
            attributed.draw(at: origin)
            return true
        }
        image.isTemplate = true
        return image
    }
}
