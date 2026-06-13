import SwiftUI
import Combine
import StoreKit

@MainActor
final class TimerViewModel: ObservableObject {

    // MARK: - Published UI state

    @Published private(set) var timeRemaining:            Int       = 25 * 60
    @Published private(set) var totalDuration:            Int       = 25 * 60
    @Published private(set) var isRunning:                Bool      = false
    @Published private(set) var currentMode:              TimerMode = .focus
    @Published private(set) var completedSessionsInCycle: Int       = 0
    @Published private(set) var todayCompletedPomodoros:  Int       = 0

    var progress: Double {
        guard totalDuration > 0 else { return 1 }
        return Double(timeRemaining) / Double(totalDuration)
    }

    var formattedTime: String {
        let m = timeRemaining / 60
        let s = timeRemaining % 60
        return String(format: "%02d:%02d", m, s)
    }

    // MARK: - Settings (read directly from UserDefaults, no @AppStorage in ViewModel)

    var workDurationMinutes: Int {
        let v = UserDefaults.standard.integer(forKey: "workDuration")
        return v > 0 ? v : 25
    }
    var shortBreakDurationMinutes: Int {
        let v = UserDefaults.standard.integer(forKey: "shortBreakDuration")
        return v > 0 ? v : 5
    }
    var longBreakDurationMinutes: Int {
        let v = UserDefaults.standard.integer(forKey: "longBreakDuration")
        return v > 0 ? v : 15
    }

    // MARK: - Dependencies

    private let timerService:        any TimerServiceProtocol
    private let audioService:        any AudioServiceProtocol
    private let notificationService: any NotificationServiceProtocol

    // MARK: - Audio state

    /// Tracks the user's sound selection so we can call play() on every start
    /// instead of relying on resume() which can fail silently.
    private var selectedSound: AmbientSound = .none

    // MARK: - Combine

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        timerService:        any TimerServiceProtocol,
        audioService:        any AudioServiceProtocol,
        notificationService: any NotificationServiceProtocol
    ) {
        self.timerService        = timerService
        self.audioService        = audioService
        self.notificationService = notificationService

        let work       = workDurationMinutes       * 60
        let shortBreak = shortBreakDurationMinutes * 60
        let longBreak  = longBreakDurationMinutes  * 60
        timerService.updateDurations(work: work, shortBreak: shortBreak, longBreak: longBreak)

        // Use .sink instead of assign(to:) to avoid Swift 6 @MainActor crossing issues
        timerService.timeRemainingPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in self?.timeRemaining = value }
            .store(in: &cancellables)

        timerService.isRunningPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in self?.isRunning = value }
            .store(in: &cancellables)

        timerService.currentModePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] mode in
                guard let self else { return }
                self.currentMode   = mode
                self.totalDuration = self.seconds(for: mode)
            }
            .store(in: &cancellables)

        timerService.sessionsInCyclePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] value in self?.completedSessionsInCycle = value }
            .store(in: &cancellables)

        timerService.sessionCompletedPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] completedMode in
                self?.handleSessionCompleted(mode: completedMode)
            }
            .store(in: &cancellables)

        totalDuration           = work
        timeRemaining           = work
        todayCompletedPomodoros = UserDefaults.standard.integer(forKey: statsKey)

        let savedSound = UserDefaults.standard.string(forKey: "selectedSound") ?? ""
        selectedSound  = AmbientSound(rawValue: savedSound) ?? .none

        Task { await notificationService.requestPermission() }
    }

    // MARK: - Actions

    func startOrPause() {
        if isRunning {
            timerService.pause()
            notificationService.cancelPendingNotifications()
            audioService.pause()
        } else {
            timerService.start()
            notificationService.scheduleTimerEnd(mode: currentMode, after: timeRemaining)
            guard selectedSound != .none else { return }
            if audioService.currentSound == selectedSound {
                // Same sound was paused — continue from where it left off
                audioService.resume()
            } else {
                // Sound changed while timer was stopped — start fresh
                audioService.play(sound: selectedSound)
            }
        }
    }

    /// Called when the user picks a sound from the picker.
    func soundSelected(_ sound: AmbientSound) {
        selectedSound = sound
        if isRunning {
            audioService.play(sound: sound)
        }
        // If timer is stopped, selection is saved; play() fires on next startOrPause().
    }

    func reset() {
        timerService.reset()
        notificationService.cancelPendingNotifications()
        audioService.pause()
        totalDuration = seconds(for: currentMode)
    }

    func skip() {
        timerService.skip()
        notificationService.cancelPendingNotifications()
        audioService.pause()
    }

    func switchMode(_ mode: TimerMode) {
        timerService.setMode(mode)
        notificationService.cancelPendingNotifications()
        audioService.pause()
        totalDuration = seconds(for: mode)
    }

    func applySettings() {
        let work       = workDurationMinutes       * 60
        let shortBreak = shortBreakDurationMinutes * 60
        let longBreak  = longBreakDurationMinutes  * 60
        timerService.updateDurations(work: work, shortBreak: shortBreak, longBreak: longBreak)
        totalDuration = seconds(for: currentMode)
    }

    // MARK: - App lifecycle

    func handleBackground()  { timerService.handleBackground() }
    func handleForeground() {
        timerService.handleForeground()
        totalDuration = seconds(for: currentMode)
    }

    // MARK: - Private

    private var statsKey: String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return "stats_\(f.string(from: Date()))"
    }

    private func handleSessionCompleted(mode: TimerMode) {
        audioService.playCompletionSound()
        if mode == .focus {
            todayCompletedPomodoros += 1
            UserDefaults.standard.set(todayCompletedPomodoros, forKey: statsKey)
            requestReviewIfEligible()
        }
        totalDuration = seconds(for: currentMode)
    }

    private func requestReviewIfEligible() {
        let totalCompleted = UserDefaults.standard.integer(forKey: "totalCompletedPomodoros") + 1
        UserDefaults.standard.set(totalCompleted, forKey: "totalCompletedPomodoros")

        // 3. oturumda ve ardından her 20 oturumda bir sor
        let shouldRequest = totalCompleted == 3 || (totalCompleted > 3 && totalCompleted % 20 == 0)
        guard shouldRequest else { return }

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }

        SKStoreReviewController.requestReview(in: scene)
    }

    private func seconds(for mode: TimerMode) -> Int {
        switch mode {
        case .focus:      return workDurationMinutes       * 60
        case .shortBreak: return shortBreakDurationMinutes * 60
        case .longBreak:  return longBreakDurationMinutes  * 60
        }
    }
}
