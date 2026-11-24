//
//  HoverIconButtonStyle.swift
//  MenuCal
//

import SwiftUI

struct HoverIconButtonStyle: ButtonStyle {
    @State private var isHovered = false

    func makeBody(configuration: Configuration) -> some View {
        let label = configuration.label
            .font(.system(size: 14))
            .frame(width: 28, height: 28)

        if #available(macOS 26, *) {
            label
                .contentShape(Circle())
                .glassEffect(.regular.interactive(), in: .circle)
        } else {
            label
                .foregroundStyle(isHovered ? .primary : .secondary)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isHovered ? Color.primary.opacity(0.08) : Color.clear)
                )
                .opacity(configuration.isPressed ? 0.7 : 1)
                .onHover { isHovered = $0 }
        }
    }
}
