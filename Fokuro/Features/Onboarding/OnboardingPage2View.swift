import SwiftUI
import StoreKit

struct OnboardingPage2View: View {
    @Environment(\.requestReview) private var requestReview
    @State private var contentOpacity: Double = 0

    private let sounds: [(icon: String, key: String)] = [
        ("music.note",      "Lo-Fi"),
        ("cloud.rain.fill", "onboarding.page2.sound.rain"),
        ("leaf.fill",       "onboarding.page2.sound.forest")
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "waveform.circle")
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(Color.fokuroFocus)

            Spacer().frame(height: 40)

            VStack(spacing: 16) {
                Text(String(localized: "onboarding.page2.title"))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding.page2.body"))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }

            Spacer().frame(height: 40)

            HStack(spacing: 16) {
                ForEach(sounds, id: \.icon) { sound in
                    SoundChip(
                        icon:  sound.icon,
                        label: String(localized: String.LocalizationValue(sound.key))
                    )
                }
            }

            Spacer()
            Spacer().frame(height: 130)
        }
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) { contentOpacity = 1 }
            Task { @MainActor in
                try? await Task.sleep(for: .milliseconds(800))
                requestReview()
            }
        }
    }
}

// MARK: - SoundChip

private struct SoundChip: View {
    let icon:  String
    let label: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 28, weight: .thin))
                .foregroundStyle(Color.fokuroFocus)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.white.opacity(0.7))
        }
        .frame(width: 90, height: 90)
        .background(Color.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingPage2View()
    }
}
