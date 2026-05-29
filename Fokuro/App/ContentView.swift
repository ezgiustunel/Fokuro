import SwiftUI

// MARK: - ContentView
//
// Root coordinator.  Services are created once in FokuroApp and passed in —
// no object construction happens here.

struct ContentView: View {

    @ObservedObject var timerVM: TimerViewModel
    let audioService: AudioService          // concrete type, no existential boxing

    @AppStorage("isDarkMode")    private var isDarkMode:       Bool   = true
    @AppStorage("selectedSound") private var selectedSoundRaw: String = AmbientSound.none.rawValue

    private var selectedSoundBinding: Binding<AmbientSound> {
        Binding(
            get:  { AmbientSound(rawValue: selectedSoundRaw) ?? .none },
            set:  { selectedSoundRaw = $0.rawValue }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            TimerView(
                viewModel:     timerVM,
                isDarkMode:    $isDarkMode,
                selectedSound: selectedSoundBinding,
                audioService:  audioService
            )

            // Banner reklam
            BannerAdView()
                .padding(.bottom, 8)
        }
        .preferredColorScheme(isDarkMode ? .dark : .light)
    }
}

// MARK: - Preview

#Preview {
    ContentView(
        timerVM:      TimerViewModel(
            timerService:        MockTimerService(),
            audioService:        MockAudioService(),
            notificationService: MockNotificationService()
        ),
        audioService: AudioService()
    )
}
