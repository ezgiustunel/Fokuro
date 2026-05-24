import UserNotifications

// MARK: - NotificationService

final class NotificationService: NotificationServiceProtocol {

    private let center = UNUserNotificationCenter.current()
    private let timerEndIdentifier = "com.fokuro.timerEnd"

    // MARK: - NotificationServiceProtocol

    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("NotificationService: permission request failed – \(error)")
            return false
        }
    }

    func scheduleTimerEnd(mode: TimerMode, after seconds: Int) {
        cancelPendingNotifications()
        guard seconds > 0 else { return }

        let content                  = UNMutableNotificationContent()
        content.title                = notificationTitle(for: mode)
        content.body                 = notificationBody(for: mode)
        content.sound                = .default
        content.interruptionLevel    = .timeSensitive

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(seconds),
            repeats: false
        )
        let request = UNNotificationRequest(
            identifier: timerEndIdentifier,
            content: content,
            trigger: trigger
        )

        center.add(request) { error in
            if let error {
                print("NotificationService: scheduling failed – \(error)")
            }
        }
    }

    func cancelPendingNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [timerEndIdentifier])
    }

    // MARK: - Private helpers

    private func notificationTitle(for mode: TimerMode) -> String {
        switch mode {
        case .focus:      return String(localized: "notification.focus.title")
        case .shortBreak: return String(localized: "notification.shortBreak.title")
        case .longBreak:  return String(localized: "notification.longBreak.title")
        }
    }

    private func notificationBody(for mode: TimerMode) -> String {
        switch mode {
        case .focus:      return String(localized: "notification.focus.body")
        case .shortBreak: return String(localized: "notification.shortBreak.body")
        case .longBreak:  return String(localized: "notification.longBreak.body")
        }
    }
}

// MARK: - Mock

final class MockNotificationService: NotificationServiceProtocol {
    func requestPermission() async -> Bool { true }
    func scheduleTimerEnd(mode: TimerMode, after seconds: Int) {}
    func cancelPendingNotifications() {}
}
