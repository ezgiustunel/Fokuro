import Observation
import GoogleMobileAds
import UIKit

// MARK: - RewardedAdService

@Observable
@MainActor
final class RewardedAdService {

    // Test ID — replace before release
    // Real format: ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN
    private let adUnitID = "ca-app-pub-3940256099942544/1712485313"

    private(set) var isAdReady = false

    private var rewardedAd: RewardedAd?
    private var adDelegate: RewardedAdDelegate?

    init() {
        adDelegate = RewardedAdDelegate(service: self)
        loadAd()
    }

    // MARK: - Public

    func loadAd() {
        Task { @MainActor in
            do {
                let ad = try await RewardedAd.load(
                    with: adUnitID,
                    request: Request()
                )
                ad.fullScreenContentDelegate = adDelegate
                rewardedAd = ad
                isAdReady  = true
            } catch {
                print("RewardedAdService: failed to load – \(error)")
                isAdReady = false
            }
        }
    }

    func showAd(onRewarded: @escaping () -> Void) {
        guard let ad = rewardedAd,
              let rootVC = rootViewController() else {
            print("RewardedAdService: ad not ready")
            return
        }
        ad.present(from: rootVC) {
            onRewarded()
        }
    }

    // MARK: - Fileprivate (delegate callbacks)

    fileprivate func adDidDismiss() {
        isAdReady  = false
        rewardedAd = nil
        loadAd()
    }

    fileprivate func adDidFailToPresent() {
        isAdReady = false
        loadAd()
    }

    // MARK: - Private

    private func rootViewController() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first?.rootViewController
    }
}

// MARK: - RewardedAdDelegate

private final class RewardedAdDelegate: NSObject, FullScreenContentDelegate {

    private weak var service: RewardedAdService?

    init(service: RewardedAdService) {
        self.service = service
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            service?.adDidDismiss()
        }
    }

    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        print("RewardedAdService: failed to present – \(error)")
        Task { @MainActor in
            service?.adDidFailToPresent()
        }
    }
}
