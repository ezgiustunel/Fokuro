import Foundation
import Combine

// MARK: - TimerService

final class TimerService: TimerServiceProtocol, ObservableObject {

    // MARK: - Published state

    @Published private(set) var timeRemaining:            Int       = 0
    @Published private(set) var isRunning:                Bool      = false
    @Published private(set) var currentMode:              TimerMode = .focus
    @Published private(set) var completedSessionsInCycle: Int       = 0

    // MARK: - Publishers

    var timeRemainingPublisher:    AnyPublisher<Int, Never>       { $timeRemaining.eraseToAnyPublisher() }
    var isRunningPublisher:        AnyPublisher<Bool, Never>      { $isRunning.eraseToAnyPublisher() }
    var currentModePublisher:      AnyPublisher<TimerMode, Never> { $currentMode.eraseToAnyPublisher() }
    var sessionsInCyclePublisher:  AnyPublisher<Int, Never>       { $completedSessionsInCycle.eraseToAnyPublisher() }
    var sessionCompletedPublisher: AnyPublisher<TimerMode, Never> { sessionCompletedSubject.eraseToAnyPublisher() }

    private let sessionCompletedSubject = PassthroughSubject<TimerMode, Never>()

    // MARK: - Private timing state

    /// When did the current run segment start?
    private var segmentStartDate:     Date?
    /// How many seconds were left when this segment started?
    private var segmentStartRemaining: Int = 0

    // MARK: - Durations (seconds)

    private var workDuration:       Int
    private var shortBreakDuration: Int
    private var longBreakDuration:  Int

    // MARK: - Combine

    private var tickCancellable: AnyCancellable?

    // MARK: - Init

    init(workDuration:       Int = 25 * 60,
         shortBreakDuration: Int = 5  * 60,
         longBreakDuration:  Int = 15 * 60) {
        self.workDuration       = workDuration
        self.shortBreakDuration = shortBreakDuration
        self.longBreakDuration  = longBreakDuration
        self.timeRemaining      = workDuration
        self.segmentStartRemaining = workDuration
    }

    // MARK: - TimerServiceProtocol

    func start() {
        guard !isRunning else { return }
        isRunning              = true
        segmentStartDate       = Date()
        segmentStartRemaining  = timeRemaining
        startTicking()
    }

    func pause() {
        guard isRunning else { return }
        syncTimeRemaining()
        isRunning        = false
        segmentStartDate = nil
        stopTicking()
    }

    func reset() {
        isRunning        = false
        segmentStartDate = nil
        stopTicking()
        let d          = duration(for: currentMode)
        timeRemaining  = d
        segmentStartRemaining = d
    }

    func skip() {
        pause()
        advanceMode()
    }

    func setMode(_ mode: TimerMode) {
        guard mode != currentMode else { return }
        pause()
        currentMode           = mode
        let d                 = duration(for: mode)
        timeRemaining         = d
        segmentStartRemaining = d
    }

    func updateDurations(work: Int, shortBreak: Int, longBreak: Int) {
        workDuration       = work
        shortBreakDuration = shortBreak
        longBreakDuration  = longBreak
        // Apply only when idle so we don't jump mid-session
        if !isRunning {
            reset()
        }
    }

    // MARK: - App-lifecycle hooks

    /// Called when the app enters the background.
    /// No-op: we rely purely on Date arithmetic, so background time is
    /// automatically accounted for when `handleForeground()` fires.
    func handleBackground() {}

    /// Called when the app returns to the foreground.
    /// Resync the displayed time and handle any sessions that completed
    /// while the app was suspended.
    func handleForeground() {
        guard isRunning else { return }
        syncTimeRemaining()
        if timeRemaining <= 0 {
            completeSession()
        }
    }

    // MARK: - Private helpers

    private func startTicking() {
        // 0.5-second cadence for a smooth countdown display
        tickCancellable = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isRunning else { return }
                self.syncTimeRemaining()
                if self.timeRemaining <= 0 {
                    self.completeSession()
                }
            }
    }

    private func stopTicking() {
        tickCancellable = nil
    }

    /// Updates `timeRemaining` by computing elapsed time since the segment started.
    private func syncTimeRemaining() {
        guard let start = segmentStartDate else { return }
        let elapsed    = Int(Date().timeIntervalSince(start))
        timeRemaining  = max(0, segmentStartRemaining - elapsed)
    }

    private func completeSession() {
        stopTicking()
        isRunning        = false
        segmentStartDate = nil
        timeRemaining    = 0

        let completedMode = currentMode

        if completedMode == .focus {
            completedSessionsInCycle += 1
        }

        sessionCompletedSubject.send(completedMode)
        advanceMode()
    }

    private func advanceMode() {
        switch currentMode {
        case .focus:
            if completedSessionsInCycle >= 4 {
                completedSessionsInCycle = 0
                currentMode   = .longBreak
                timeRemaining = longBreakDuration
            } else {
                currentMode   = .shortBreak
                timeRemaining = shortBreakDuration
            }
        case .shortBreak, .longBreak:
            currentMode   = .focus
            timeRemaining = workDuration
        }
        segmentStartRemaining = timeRemaining
    }

    private func duration(for mode: TimerMode) -> Int {
        switch mode {
        case .focus:      return workDuration
        case .shortBreak: return shortBreakDuration
        case .longBreak:  return longBreakDuration
        }
    }
}

// MARK: - Mock (Preview / Testing)

final class MockTimerService: TimerServiceProtocol {
    var timeRemaining:            Int       = 25 * 60
    var isRunning:                Bool      = false
    var currentMode:              TimerMode = .focus
    var completedSessionsInCycle: Int       = 2

    var timeRemainingPublisher:    AnyPublisher<Int, Never>       { Just(timeRemaining).eraseToAnyPublisher() }
    var isRunningPublisher:        AnyPublisher<Bool, Never>      { Just(isRunning).eraseToAnyPublisher() }
    var currentModePublisher:      AnyPublisher<TimerMode, Never> { Just(currentMode).eraseToAnyPublisher() }
    var sessionsInCyclePublisher:  AnyPublisher<Int, Never>       { Just(completedSessionsInCycle).eraseToAnyPublisher() }
    var sessionCompletedPublisher: AnyPublisher<TimerMode, Never> { Empty().eraseToAnyPublisher() }

    func start() {}
    func pause() {}
    func reset() {}
    func skip()  {}
    func setMode(_ mode: TimerMode) {}
    func updateDurations(work: Int, shortBreak: Int, longBreak: Int) {}
    func handleBackground() {}
    func handleForeground() {}
}
