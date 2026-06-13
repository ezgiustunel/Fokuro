import SwiftUI

@main
struct FokuroApp: App {

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var timerVM:     TimerViewModel
    @StateObject private var audioService: AudioService
    @State private var rewardedAdService:     RewardedAdService
    @State private var interstitialAdService: InterstitialAdService

    init() {
        ATTService.shared.requestAndInitialiseAds()

        let au  = AudioService()
        let ts  = TimerService()
        let ns  = NotificationService()
        let ias = InterstitialAdService()

        _audioService         = StateObject(wrappedValue: au)
        _rewardedAdService    = State(wrappedValue: RewardedAdService())
        _interstitialAdService = State(wrappedValue: ias)
        _timerVM = StateObject(wrappedValue: TimerViewModel(
            timerService:         ts,
            audioService:         au,
            notificationService:  ns,
            interstitialAdService: ias
        ))
    }

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(
                    timerVM:           timerVM,
                    audioService:      audioService,
                    rewardedAdService: rewardedAdService
                )
                .opacity(showSplash ? 0 : 1)

                if showSplash {
                    SplashView()
                        .transition(.opacity)
                        .zIndex(1)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    withAnimation(.easeOut(duration: 0.4)) {
                        showSplash = false
                    }
                }
            }
        }
        .onChange(of: scenePhase) { _, phase in
            switch phase {
            case .background: timerVM.handleBackground()
            case .active:     timerVM.handleForeground()
            default: break
            }
        }
    }
}
