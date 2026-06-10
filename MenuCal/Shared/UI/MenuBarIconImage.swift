//
//  MenuBarIconImage.swift
//  MenuCal
//
//  Created by gp on 2026/6/8.
//

import AppKit

// Custom date / weekday icons rendered as template images so they tint with the
// menu bar. SF Symbols has no day-specific calendar glyph, so they are drawn
// with AppKit and cached (they only change daily).
@MainActor
enum MenuBarIconImage {
    private static var cache: [MenuBarCalendarGlyph: NSImage] = [:]

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
            case .calendarGlyph(let glyph):
                return glyphImage(for: glyph)
            case .icon(let systemName):
                return symbol(systemName, pointSize: 16)
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

    static func glyphImage(for glyph: MenuBarCalendarGlyph) -> NSImage {
        if let cached = cache[glyph] { return cached }
        let image = draw(glyph: glyph)
        cache[glyph] = image
        return image
    }

    private static func draw(glyph: MenuBarCalendarGlyph) -> NSImage {
        if glyph.headerText != nil {
            return drawFilledDate(glyph)
        }
        return drawOutlinedGlyph(glyph.bodyText)
    }

    private static func drawFilledDate(_ glyph: MenuBarCalendarGlyph) -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setFill()
            NSBezierPath(roundedRect: rect.insetBy(dx: 0.5, dy: 0.5), xRadius: 2.5, yRadius: 2.5).fill()

            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current?.compositingOperation = .destinationOut

            if let headerText = glyph.headerText {
                let headerAttributes: [NSAttributedString.Key: Any] = [
                    .font: NSFont.systemFont(ofSize: 7, weight: .medium),
                    .foregroundColor: NSColor.white,
                ]
                let header = NSAttributedString(string: headerText, attributes: headerAttributes)
                let headerSize = header.size()
                header.draw(at: NSPoint(
                    x: rect.midX - headerSize.width / 2,
                    y: 9.1
                ))
            }

            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: 9, weight: .medium),
                .foregroundColor: NSColor.white,
            ]
            let body = NSAttributedString(string: glyph.bodyText, attributes: bodyAttributes)
            let bodySize = body.size()
            body.draw(at: NSPoint(
                x: rect.midX - bodySize.width / 2,
                y: 0.6
            ))

            NSGraphicsContext.restoreGraphicsState()
            return true
        }
        image.isTemplate = true
        return image
    }

    private static func drawOutlinedGlyph(_ text: String) -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setStroke()

            let body = rect.insetBy(dx: 0.65, dy: 0.65)
            let bodyPath = NSBezierPath(roundedRect: body, xRadius: 3, yRadius: 3)
            bodyPath.lineWidth = 1.3
            bodyPath.stroke()

            let headerY = body.maxY - 5
            let divider = NSBezierPath()
            divider.move(to: NSPoint(x: body.minX + 1, y: headerY))
            divider.line(to: NSPoint(x: body.maxX - 1, y: headerY))
            divider.lineWidth = 1.1
            divider.stroke()

            let bodyFontSize: CGFloat = text.count > 1 ? 8 : 9.5
            let bodyAttributes: [NSAttributedString.Key: Any] = [
                .font: NSFont.systemFont(ofSize: bodyFontSize, weight: .bold),
                .foregroundColor: NSColor.black,
            ]
            let attributed = NSAttributedString(string: text, attributes: bodyAttributes)
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
