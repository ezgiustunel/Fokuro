import SwiftUI
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {

    // MARK: - Persisted settings

    @AppStorage("workDuration")       var workDuration:       Int = 25
    @AppStorage("shortBreakDuration") var shortBreakDuration: Int = 5
    @AppStorage("longBreakDuration")  var longBreakDuration:  Int = 15
    @AppStorage("isDarkMode")         var isDarkMode:         Bool = true
    @AppStorage("selectedSound")      var selectedSoundRaw:   String = AmbientSound.none.rawValue
    @AppStorage("ambientVolume")      var ambientVolume:      Double = 0.5

    var selectedSound: AmbientSound {
        get { AmbientSound(rawValue: selectedSoundRaw) ?? .none }
        set { selectedSoundRaw = newValue.rawValue }
    }

    // MARK: - Dependencies

    private let audioService: any AudioServiceProtocol
    var onSettingsChanged: (() -> Void)?

    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(audioService: any AudioServiceProtocol) {
        self.audioService = audioService
    }

    // MARK: - Actions

    func applyAndDismiss() {
        onSettingsChanged?()
    }

    func selectSound(_ sound: AmbientSound) {
        selectedSound = sound
        if sound == .none {
            audioService.stop()
        } else {
            audioService.play(sound: sound)
            audioService.setVolume(Float(ambientVolume))
        }
    }

    func updateVolume(_ newVolume: Double) {
        ambientVolume = newVolume
        audioService.setVolume(Float(newVolume))
    }

    // MARK: - Validation helpers

    var workDurationRange:       ClosedRange<Int> { 1...60 }
    var shortBreakDurationRange: ClosedRange<Int> { 1...30 }
    var longBreakDurationRange:  ClosedRange<Int> { 5...60 }
}
