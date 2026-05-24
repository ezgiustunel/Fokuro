import SwiftUI

// MARK: - Fokuro Design System Colours

extension Color {
    // ── Backgrounds (adaptive: dark = OLED-first, light = system) ────────
    static let fokuroBackground      = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? .black
            : .systemBackground
    })
    static let fokuroSurface         = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.07, green: 0.07, blue: 0.08, alpha: 1)
            : UIColor.systemGray6
    })
    static let fokuroSurfaceElevated = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.14, alpha: 1)
            : UIColor.systemGray5
    })
    static let fokuroBorder          = Color(UIColor { t in
        t.userInterfaceStyle == .dark
            ? UIColor(white: 0.18, alpha: 1)
            : UIColor.systemGray4
    })

    // ── Mode Accents (same in both modes) ────────────────────────────────
    /// Warm ember – focus sessions
    static let fokuroFocus      = Color(red: 1.00, green: 0.47, blue: 0.19)
    /// Mint – short breaks
    static let fokuroShortBreak = Color(red: 0.28, green: 0.82, blue: 0.56)
    /// Sky – long breaks
    static let fokuroLongBreak  = Color(red: 0.29, green: 0.62, blue: 1.00)

    // ── Text (adaptive) ───────────────────────────────────────────────────
    static let fokuroText    = Color(UIColor.label)
    static let fokuroSubtext = Color(UIColor.secondaryLabel)
    static let fokuroMuted   = Color(UIColor.tertiaryLabel)

    // ── Glow helpers (used in ring shadows) ──────────────────────────────
    static let fokuroFocusGlow      = Color(red: 1.00, green: 0.47, blue: 0.19).opacity(0.35)
    static let fokuroShortBreakGlow = Color(red: 0.28, green: 0.82, blue: 0.56).opacity(0.35)
    static let fokuroLongBreakGlow  = Color(red: 0.29, green: 0.62, blue: 1.00).opacity(0.35)
}

// MARK: - Mode-aware helpers

extension Color {
    static func fokuroAccent(for mode: TimerMode) -> Color {
        switch mode {
        case .focus:      return .fokuroFocus
        case .shortBreak: return .fokuroShortBreak
        case .longBreak:  return .fokuroLongBreak
        }
    }

    static func fokuroGlow(for mode: TimerMode) -> Color {
        switch mode {
        case .focus:      return .fokuroFocusGlow
        case .shortBreak: return .fokuroShortBreakGlow
        case .longBreak:  return .fokuroLongBreakGlow
        }
    }
}

// MARK: - ShapeStyle convenience (enables .foregroundStyle(.fokuroText) syntax)
//
// `foregroundStyle` accepts `some ShapeStyle`. Without these extensions the
// compiler cannot infer the type from a leading-dot shorthand like `.fokuroText`
// because it looks for the member on `ShapeStyle`, not `Color`.

extension ShapeStyle where Self == Color {
    static var fokuroBackground:      Color { .fokuroBackground }
    static var fokuroSurface:         Color { .fokuroSurface }
    static var fokuroSurfaceElevated: Color { .fokuroSurfaceElevated }
    static var fokuroBorder:          Color { .fokuroBorder }
    static var fokuroFocus:           Color { .fokuroFocus }
    static var fokuroShortBreak:      Color { .fokuroShortBreak }
    static var fokuroLongBreak:       Color { .fokuroLongBreak }
    static var fokuroText:            Color { .fokuroText }
    static var fokuroSubtext:         Color { .fokuroSubtext }
    static var fokuroMuted:           Color { .fokuroMuted }
}

// MARK: - Gradient helpers

extension LinearGradient {
    static func fokuroRingGradient(for mode: TimerMode) -> LinearGradient {
        let accent = Color.fokuroAccent(for: mode)
        let lighter = accent.opacity(0.7)
        return LinearGradient(
            colors: [lighter, accent],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
