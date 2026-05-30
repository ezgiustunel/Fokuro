import AppTrackingTransparency
import GoogleMobileAds

// MARK: - ATTService
//
// Requests App Tracking Transparency permission, then initialises
// Google Mobile Ads so ads load with the correct consent status.

final class ATTService {

    static let shared = ATTService()
    private init() {}

    func requestAndInitialiseAds() {
        // ATT dialog must be shown while app is in foreground active state.
        // We wait 1 second after launch so the splash has settled.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            ATTrackingManager.requestTrackingAuthorization { status in
                // Initialise Mobile Ads regardless of the user's choice.
                // When denied, AdMob serves non-personalised ads.
                DispatchQueue.main.async {
                    MobileAds.shared.start()
                }

                switch status {
                case .authorized:
                    print("ATT: authorised ✅")
                case .denied:
                    print("ATT: denied — non-personalised ads will be served")
                case .restricted:
                    print("ATT: restricted")
                case .notDetermined:
                    print("ATT: not determined")
                @unknown default:
                    break
                }
            }
        }
    }
}
