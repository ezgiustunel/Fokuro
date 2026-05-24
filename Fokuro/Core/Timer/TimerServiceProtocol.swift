import Foundation
import Combine

// MARK: - Models

enum TimerMode: String, CaseIterable {
    case focus      = "focus"
    case shortBreak = "shortBreak"
    case longBreak  = "longBreak"

    var displayName: String {
        switch self {
        case .focus:      return String(localized: "Focus")
        case .shortBreak: return String(localized: "Short Break")
        case .longBreak:  return String(localized: "Long Break")
        }
    }

    var icon: String {
        switch self {
        case .focus:      return "brain.head.profile"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak:  return "figure.walk"
        }
    }
}

enum AmbientSound: String, CaseIterable, Identifiable {
    case none   = "none"
    case lofi   = "lofi"
    case rain   = "rain"
    case forest = "forest"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none:   return String(localized: "Silent")
        case .lofi:   return String(localized: "Lo-Fi")
        case .rain:   return String(localized: "Rain")
        case .forest: return String(localized: "Forest")
        }
    }

    var icon: String {
        switch self {
        case .none:   return "speaker.slash.fill"
        case .lofi:   return "music.note"
        case .rain:   return "cloud.rain.fill"
        case .forest: return "leaf.fill"
        }
    }

    /// Bundle filename (nil = silent)
    var filename: String? {
        switch self {
        case .none:   return nil
        case .lofi:   return "lofi"
        case .rain:   return "rain"
        case .forest: return "forest"
        }
    }
}

// MARK: - Protocol

protocol TimerServiceProtocol: AnyObject {
    // MARK: Publishers
    var timeRemainingPublisher:     AnyPublisher<Int, Never>       { get }
    var isRunningPublisher:         AnyPublisher<Bool, Never>      { get }
    var currentModePublisher:       AnyPublisher<TimerMode, Never> { get }
    var sessionsInCyclePublisher:   AnyPublisher<Int, Never>       { get }
    var sessionCompletedPublisher:  AnyPublisher<TimerMode, Never> { get }

    // MARK: State (synchronous snapshots)
    var timeRemaining:             Int       { get }
    var isRunning:                 Bool      { get }
    var currentMode:               TimerMode { get }
    var completedSessionsInCycle:  Int       { get }

    // MARK: Actions
    func start()
    func pause()
    func reset()
    func skip()
    func setMode(_ mode: TimerMode)
    func updateDurations(work: Int, shortBreak: Int, longBreak: Int)

    // MARK: App-lifecycle hooks
    func handleBackground()
    func handleForeground()
}
