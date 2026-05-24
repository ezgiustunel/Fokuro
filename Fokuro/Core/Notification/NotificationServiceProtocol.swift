import Foundation

protocol NotificationServiceProtocol: AnyObject {
    func requestPermission() async -> Bool
    func scheduleTimerEnd(mode: TimerMode, after seconds: Int)
    func cancelPendingNotifications()
}
