import SwiftUI

struct OnboardingPage1View: View {
    @State private var iconScale:   CGFloat = 0.7
    @State private var iconOpacity: Double  = 0
    @State private var textOpacity: Double  = 0
    @State private var ringTrim:    Double  = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.08), lineWidth: 6)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: ringTrim)
                    .stroke(
                        Color.fokuroFocus,
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Image(systemName: "timer")
                    .font(.system(size: 38, weight: .thin))
                    .foregroundStyle(Color.fokuroFocus)
            }
            .scaleEffect(iconScale)
            .opacity(iconOpacity)

            Spacer().frame(height: 48)

            VStack(spacing: 16) {
                Text(String(localized: "onboarding.page1.title"))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding.page1.body"))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .opacity(textOpacity)
            .padding(.horizontal, 40)

            Spacer()
            Spacer().frame(height: 130)
        }
        .onAppear { animate() }
    }

    private func animate() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            iconScale   = 1
            iconOpacity = 1
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
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingPage1View()
    }
}
