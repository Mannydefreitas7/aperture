import SwiftUI
import AppKit
import Combine

// MARK: - Mouse Click Visualizer

class MouseClickVisualizer: ObservableObject {
    static let shared = MouseClickVisualizer()
    
    @Published var clicks: [ClickEvent] = []
    @Published var isEnabled = false
    @Published var highlightColor: Color = .yellow
    @Published var highlightSize: CGFloat = 40
    @Published var animationDuration: Double = 0.3
    @Published var showRipple = true
    
    private var eventMonitor: Any?
    private var cleanupTimer: Timer?
    
    struct ClickEvent: Identifiable {
        let id = UUID()
        let location: CGPoint
        let timestamp: Date
        let isRightClick: Bool
        var phase: ClickPhase = .started
    }
    
    enum ClickPhase {
        case started
        case ended
    }
    
    init() {}
    
    func start() {
        guard eventMonitor == nil else { return }
        isEnabled = true
        
        // Monitor mouse clicks
        eventMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .leftMouseUp, .rightMouseDown, .rightMouseUp]
        ) { [weak self] event in
            self?.handleMouseEvent(event)
        }
        
        // Setup cleanup timer
        cleanupTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.cleanupOldClicks()
        }
    }
    
    func stop() {
        isEnabled = false
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        cleanupTimer?.invalidate()
        cleanupTimer = nil
        
        clicks.removeAll()
    }
    
    private func handleMouseEvent(_ event: NSEvent) {
        let isRightClick = event.type == .rightMouseDown || event.type == .rightMouseUp
        let isMouseDown = event.type == .leftMouseDown || event.type == .rightMouseDown
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if isMouseDown {
                let click = ClickEvent(
                    location: event.locationInWindow,
                    timestamp: Date(),
                    isRightClick: isRightClick
                )
                self.clicks.append(click)
            } else {
                // Mark last click of this type as ended
                if let index = self.clicks.lastIndex(where: { $0.isRightClick == isRightClick && $0.phase == .started }) {
                    self.clicks[index].phase = .ended
                }
            }
        }
    }
    
    private func cleanupOldClicks() {
        let cutoff = Date().addingTimeInterval(-1.0)
        clicks.removeAll { $0.timestamp < cutoff && $0.phase == .ended }
    }
}

// MARK: - Click Highlight View

struct ClickHighlightView: View {
    let click: MouseClickVisualizer.ClickEvent
    let color: Color
    let size: CGFloat
    let showRipple: Bool
    
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0
    @State private var rippleScale: CGFloat = 1.0
    @State private var rippleOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Ripple effect
            if showRipple {
                Circle()
                    .stroke(color.opacity(rippleOpacity), lineWidth: 2)
                    .frame(width: size * rippleScale, height: size * rippleScale)
            }
            
            // Main highlight
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: size * scale, height: size * scale)
            
            Circle()
                .stroke(color, lineWidth: 3)
                .frame(width: size * scale, height: size * scale)
            
            // Inner dot
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
                .opacity(click.phase == .started ? 1 : 0)
        }
        .position(click.location)
        .onAppear {
            withAnimation(.easeOut(duration: 0.15)) {
                scale = 1.0
            }
            
            if showRipple {
                withAnimation(.easeOut(duration: 0.4)) {
                    rippleScale = 2.0
                    rippleOpacity = 0
                }
            }
        }
        .onChange(of: click.phase) { _, newPhase in
            if newPhase == .ended {
                withAnimation(.easeIn(duration: 0.2)) {
                    scale = 0.3
                    opacity = 0
                }
            }
        }
        .opacity(opacity)
    }
}

// MARK: - Mouse Visualizer Overlay

struct MouseVisualizerOverlay: View {
    @ObservedObject var visualizer: MouseClickVisualizer
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(visualizer.clicks) { click in
                    ClickHighlightView(
                        click: click,
                        color: visualizer.highlightColor,
                        size: visualizer.highlightSize,
                        showRipple: visualizer.showRipple
                    )
                }
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Mouse Cursor Visualizer

class MouseCursorVisualizer: ObservableObject {
    static let shared = MouseCursorVisualizer()
    
    @Published var currentPosition: CGPoint = .zero
    @Published var isEnabled = false
    @Published var showTrail = false
    @Published var trailLength = 10
    @Published var cursorHighlight = false
    @Published var highlightColor: Color = .blue
    
    private var eventMonitor: Any?
    private var positionHistory: [CGPoint] = []
    
    func start() {
        guard eventMonitor == nil else { return }
        isEnabled = true
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: .mouseMoved) { [weak self] event in
            DispatchQueue.main.async {
                self?.updatePosition(event.locationInWindow)
            }
        }
    }
    
    func stop() {
        isEnabled = false
        
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
            eventMonitor = nil
        }
        
        positionHistory.removeAll()
    }
    
    private func updatePosition(_ position: CGPoint) {
        currentPosition = position
        
        if showTrail {
            positionHistory.append(position)
            if positionHistory.count > trailLength {
                positionHistory.removeFirst()
            }
        }
    }
}

// MARK: - Cursor Highlight View

struct CursorHighlightView: View {
    @ObservedObject var visualizer: MouseCursorVisualizer
    
    var body: some View {
        if visualizer.cursorHighlight {
            Circle()
                .fill(visualizer.highlightColor.opacity(0.2))
                .frame(width: 50, height: 50)
                .position(visualizer.currentPosition)
                .allowsHitTesting(false)
        }
    }
}

