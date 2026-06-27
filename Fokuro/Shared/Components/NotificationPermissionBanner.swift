import SwiftUI
import UserNotifications

struct NotificationPermissionBanner: View {
    let onDismiss: (_ permanently: Bool) -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(spacing: 12) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 20, weight: .light))
                    .foregroundStyle(Color.fokuroFocus)

                VStack(alignment: .leading, spacing: 2) {
                    Text(String(localized: "notification.banner.title"))
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.fokuroText)

                    Text(String(localized: "notification.banner.body"))
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(Color.fokuroSubtext)
                }

                Spacer()

                HStack(spacing: 8) {
                    Button {
                        onDismiss(true)
                    } label: {
                        Text(String(localized: "notification.banner.dismiss"))
                            .font(.system(size: 12, weight: .medium))
                            .lineLimit(1)
                            .fixedSize()
                            .foregroundStyle(Color.fokuroSubtext)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.fokuroSurface)
                            .clipShape(Capsule())
                    }

                    Button {
                        Task { await requestOrOpenSettings() }
                    } label: {
                        Text(String(localized: "notification.banner.allow"))
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                            .fixedSize()
                            .foregroundStyle(.black)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.fokuroFocus)
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.fokuroSurfaceElevated)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.fokuroBorder, lineWidth: 0.5)
            )
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
    }

    private func requestOrOpenSettings() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            _ = try? await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            onDismiss(false)
        case .denied:
            if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
                await UIApplication.shared.open(url)
            }
            onDismiss(false)
        default:
            onDismiss(false)
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        NotificationPermissionBanner(onDismiss: { _ in })
    }
}
