import SwiftUI

@main
struct FokuroApp: App {

    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var audioService = AudioService()

    @StateObject private var timerVM: TimerViewModel = {
        let ts = TimerService()
        let au = AudioService()
        let ns = NotificationService()
        return TimerViewModel(
            timerService:        ts,
            audioService:        au,
            notificationService: ns
        )
    }()

    @State private var showSplash = true

    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView(timerVM: timerVM, audioService: audioService)
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
