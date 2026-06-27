import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentPage = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                OnboardingPage1View().tag(0)
                OnboardingPage2View().tag(1)
                OnboardingPage3View { hasSeenOnboarding = true }.tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()

            VStack(spacing: 20) {
                pageIndicator

                if currentPage < 2 {
                    nextButton
                }
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 52)
        }
        .background(Color.black.ignoresSafeArea())
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? Color.fokuroFocus : Color.white.opacity(0.25))
                    .frame(width: i == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
            }
        }
    }

    private var nextButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) { currentPage += 1 }
        } label: {
            Text(String(localized: "onboarding.button.next"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.fokuroFocus)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    OnboardingView()
}
