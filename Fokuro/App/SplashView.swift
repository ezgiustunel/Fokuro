import SwiftUI

struct SplashView: View {

    @State private var logoScale:   CGFloat = 0.7
    @State private var logoOpacity: Double  = 0
    @State private var textOpacity: Double  = 0
    @State private var ringTrim:    Double  = 0

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                // ── Animated ring + icon ──────────────────────────────────
                ZStack {
                    // Background ring
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 6)
                        .frame(width: 100, height: 100)

                    // Animated accent ring
                    Circle()
                        .trim(from: 0, to: ringTrim)
                        .stroke(
                            Color.fokuroFocus,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 100, height: 100)
                        .rotationEffect(.degrees(-90))

                    // Timer icon
                    Image(systemName: "timer")
                        .font(.system(size: 38, weight: .thin))
                        .foregroundStyle(Color.fokuroFocus)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // ── App name ──────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("Fokuro")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Focus. Create. Rest.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.45))
                        .tracking(1.5)
                }
                .opacity(textOpacity)
            }
        }
        .onAppear { animate() }
    }

    private func animate() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            logoScale   = 1
            logoOpacity = 1
        }
        withAnimation(.easeInOut(duration: 0.8).delay(0.25)) {
            ringTrim = 0.75
        }
        withAnimation(.easeIn(duration: 0.5).delay(0.35)) {
            textOpacity = 1
        }
    }
}

#Preview {
    SplashView()
}
