import Foundation
import Combine

protocol AudioServiceProtocol: AnyObject {
    var currentSoundPublisher: AnyPublisher<AmbientSound, Never> { get }
    var volumePublisher:       AnyPublisher<Float, Never>        { get }
    var isPlayingPublisher:    AnyPublisher<Bool, Never>         { get }

    var currentSound: AmbientSound { get }
    var volume:       Float        { get }
    var isPlaying:    Bool         { get }

    func play(sound: AmbientSound)
    func stop()
    func pause()
    func resume()
    func setVolume(_ volume: Float)
    func playCompletionSound()
}
