import Observation
import GoogleMobileAds
import UIKit

// MARK: - InterstitialAdService

@Observable
@MainActor
final class InterstitialAdService {

    // Test ID — replace before release
    // Real format: ca-app-pub-XXXXXXXXXXXXXXXX/NNNNNNNNNN
    private let adUnitID = "ca-app-pub-3940256099942544/4411468910"

    private(set) var isAdReady = false

    private var interstitialAd: InterstitialAd?
    private var adDelegate: InterstitialAdDelegate?

    init() {
        adDelegate = InterstitialAdDelegate(service: self)
        loadAd()
    }

    // MARK: - Public

    func loadAd() {
        Task { @MainActor in
            do {
                let ad = try await InterstitialAd.load(
                    with: adUnitID,
                    request: Request()
                )
                ad.fullScreenContentDelegate = adDelegate
                interstitialAd = ad
                isAdReady      = true
            } catch {
                print("InterstitialAdService: failed to load – \(error)")
                isAdReady = false
            }
        }
    }

    func showAd() {
        guard let ad = interstitialAd,
              let rootVC = rootViewController() else {
            print("InterstitialAdService: ad not ready")
            return
        }
        ad.present(from: rootVC)
    }

    // MARK: - Fileprivate (delegate callbacks)

    fileprivate func adDidDismiss() {
        isAdReady      = false
        interstitialAd = nil
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

// MARK: - InterstitialAdDelegate

private final class InterstitialAdDelegate: NSObject, FullScreenContentDelegate {

    private weak var service: InterstitialAdService?

    init(service: InterstitialAdService) {
        self.service = service
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        Task { @MainActor in
            service?.adDidDismiss()
        }
    }

    func ad(_ ad: FullScreenPresentingAd,
            didFailToPresentFullScreenContentWithError error: Error) {
        print("InterstitialAdService: failed to present – \(error)")
        Task { @MainActor in
            service?.adDidFailToPresent()
        }
    }
}
