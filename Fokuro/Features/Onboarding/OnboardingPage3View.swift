import SwiftUI

struct OnboardingPage3View: View {
    let onStart: () -> Void

    @State private var contentOpacity: Double  = 0
    @State private var isRequesting:   Bool    = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "bell.circle")
                .font(.system(size: 72, weight: .thin))
                .foregroundStyle(Color.fokuroFocus)

            Spacer().frame(height: 40)

            VStack(spacing: 16) {
                Text(String(localized: "onboarding.page3.title"))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(String(localized: "onboarding.page3.body"))
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    guard !isRequesting else { return }
                    isRequesting = true
                    Task {
                        _ = await NotificationService().requestPermission()
                        onStart()
                    }
                } label: {
                    Text(String(localized: "onboarding.button.allowNotifications"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.fokuroFocus)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(isRequesting)

                Button { onStart() } label: {
                    Text(String(localized: "onboarding.button.skipNotifications"))
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Color.white.opacity(0.45))
                        .frame(height: 44)
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 52)
        }
        .opacity(contentOpacity)
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) { contentOpacity = 1 }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        OnboardingPage3View(onStart: {})
    }
}
