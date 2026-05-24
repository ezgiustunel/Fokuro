import SwiftUI

// MARK: - ProgressRingView
//
// A circular progress ring drawn with two overlapping Circle strokes.
//  • The track is always visible at low opacity.
//  • The progress arc uses a gradient matching the current TimerMode.
//  • A soft glow shadow pulses while the timer is running.

struct ProgressRingView: View {

    let progress:  Double    // 0…1
    let mode:      TimerMode
    let isRunning: Bool
    var lineWidth: CGFloat = 14

    // Pulsing glow animation
    @State private var glowOpacity: Double = 0.4

    var body: some View {
        ZStack {
            // ── Track ────────────────────────────────────────────────────
            Circle()
                .stroke(
                    Color.fokuroBorder,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )

            // ── Progress arc ─────────────────────────────────────────────
            Circle()
                .trim(from: 0, to: clampedProgress)
                .stroke(
                    LinearGradient.fokuroRingGradient(for: mode),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                // Glow effect
                .shadow(color: Color.fokuroGlow(for: mode).opacity(glowOpacity),
                        radius: 12, x: 0, y: 0)
                .animation(.easeInOut(duration: 0.4), value: clampedProgress)
                .animation(.easeInOut(duration: 0.4), value: mode)
        }
        .onAppear { startGlowAnimation() }
        .onChange(of: isRunning) { _, running in
            if running { startGlowAnimation() } else { glowOpacity = 0.25 }
        }
    }

    // MARK: - Private

    private var clampedProgress: Double {
        min(max(progress, 0), 1)
    }

    private func startGlowAnimation() {
        guard isRunning else { return }
        withAnimation(
            .easeInOut(duration: 1.8)
            .repeatForever(autoreverses: true)
        ) {
            glowOpacity = 0.7
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.fokuroBackground.ignoresSafeArea()
        ProgressRingView(progress: 0.65, mode: .focus, isRunning: true)
            .frame(width: 260, height: 260)
    }
}
