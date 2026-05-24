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
    @AppStorage("ambientVolume") private var ambientVolume:    Double = 0.5

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
                ambientVolume: $ambientVolume,
                audioService:  audioService
            )

            // Banner reklam alanı (Faz 2)
            Color.clear
                .frame(height: 50)
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
