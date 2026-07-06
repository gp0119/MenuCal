import AppKit
import SwiftUI

extension View {
    func overlayScrollerStyle() -> some View {
        background(OverlayScrollerStyleAccessor())
    }
}

private struct OverlayScrollerStyleAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        OverlayScrollerStyleView()
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        (nsView as? OverlayScrollerStyleView)?.configureEnclosingScrollView()
    }
}

private final class OverlayScrollerStyleView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configureEnclosingScrollView()
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        configureEnclosingScrollView()
    }

    func configureEnclosingScrollView() {
        DispatchQueue.main.async { [weak self] in
            guard let scrollView = self?.enclosingScrollView else { return }
            scrollView.scrollerStyle = .overlay
            scrollView.scrollerKnobStyle = .default
            scrollView.autohidesScrollers = true
            scrollView.hasVerticalScroller = true
            scrollView.hasHorizontalScroller = false
            scrollView.scrollerInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            scrollView.verticalScroller?.controlSize = .small
        }
    }
}
