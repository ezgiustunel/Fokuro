import AVFoundation
import AudioToolbox
import Combine

// MARK: - AudioService

final class AudioService: AudioServiceProtocol, ObservableObject {

    // MARK: - Published state

    @Published private(set) var currentSound: AmbientSound = .none
    @Published private(set) var volume:       Float        = 0.5
    @Published private(set) var isPlaying:    Bool         = false

    // MARK: - Publishers

    var currentSoundPublisher: AnyPublisher<AmbientSound, Never> { $currentSound.eraseToAnyPublisher() }
    var volumePublisher:       AnyPublisher<Float, Never>        { $volume.eraseToAnyPublisher() }
    var isPlayingPublisher:    AnyPublisher<Bool, Never>         { $isPlaying.eraseToAnyPublisher() }

    // MARK: - Private

    private var player:           AVAudioPlayer?
    private var completionPlayer: AVAudioPlayer?

    // MARK: - Init

    init() {
        configureAudioSession()
    }

    // MARK: - AudioServiceProtocol

    func play(sound: AmbientSound) {
        guard sound != currentSound || !isPlaying else { return }
        stopAll()
        currentSound = sound

        guard sound != .none else { return }

        startFilePlayback(sound: sound)
    }

    func stop() {
        stopAll()
        currentSound = .none
        isPlaying    = false
    }

    func pause() {
        player?.pause()
        isPlaying = false
    }

    func resume() {
        guard currentSound != .none else { return }
        if let player {
            player.play()
            isPlaying = true
        } else {
            // Player was lost — rebuild from scratch
            startFilePlayback(sound: currentSound)
        }
    }

    func setVolume(_ newVolume: Float) {
        volume         = newVolume
        player?.volume = newVolume
    }

    func playCompletionSound() {
        pause()
        guard let url = Bundle.main.url(forResource: "completion", withExtension: "mp3") else {
            AudioServicesPlaySystemSound(1005)
            return
        }
        do {
            completionPlayer               = try AVAudioPlayer(contentsOf: url)
            completionPlayer?.volume       = 1.0
            completionPlayer?.numberOfLoops = 0
            completionPlayer?.prepareToPlay()
            completionPlayer?.play()
        } catch {
            print("AudioService: completion sound error – \(error)")
            AudioServicesPlaySystemSound(1005)
        }
    }

    // MARK: - Private helpers

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("AudioService: AVAudioSession setup failed – \(error)")
        }
    }

    private func startFilePlayback(sound: AmbientSound) {
        guard
            let filename = sound.filename,
            let url = Bundle.main.url(forResource: filename, withExtension: "mp3")
        else {
            print("AudioService: '\(sound.rawValue).mp3' not found in bundle.")
            return
        }

        do {
            player             = try AVAudioPlayer(contentsOf: url)
            player?.volume     = volume
            player?.numberOfLoops = -1 // infinite loop
            player?.prepareToPlay()
            player?.play()
            isPlaying = true
        } catch {
            print("AudioService: AVAudioPlayer error – \(error)")
        }
    }

    private func stopAll() {
        player?.stop()
        player = nil
    }
}

// MARK: - Mock

final class MockAudioService: AudioServiceProtocol {
    var currentSound: AmbientSound = .none
    var volume:       Float        = 0.5
    var isPlaying:    Bool         = false

    var currentSoundPublisher: AnyPublisher<AmbientSound, Never> { Just(currentSound).eraseToAnyPublisher() }
    var volumePublisher:       AnyPublisher<Float, Never>        { Just(volume).eraseToAnyPublisher() }
    var isPlayingPublisher:    AnyPublisher<Bool, Never>         { Just(isPlaying).eraseToAnyPublisher() }

    func play(sound: AmbientSound) { currentSound = sound; isPlaying = sound != .none }
    func stop()                    { isPlaying = false; currentSound = .none }
    func pause()                   { isPlaying = false }
    func resume()                  { isPlaying = currentSound != .none }
    func setVolume(_ v: Float)     { volume = v }
    func playCompletionSound()     {}
}
