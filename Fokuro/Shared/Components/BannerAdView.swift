import SwiftUI
import GoogleMobileAds

// MARK: - BannerAdView

struct BannerAdView: View {

    @State private var adHeight: CGFloat = 50

    var body: some View {
        BannerViewContainer(adHeight: $adHeight)
            .frame(height: adHeight)
    }
}

// MARK: - BannerViewContainer

private struct BannerViewContainer: UIViewRepresentable {

    // Test ID — replace with real ad unit ID before release
    let adUnitID: String = "ca-app-pub-1729511345070865/9681743032"

    @Binding var adHeight: CGFloat

    func makeUIView(context: Context) -> BannerView {
        let screenWidth = UIScreen.main.bounds.width
        let adSize      = currentOrientationAnchoredAdaptiveBanner(width: screenWidth)

        let banner      = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        banner.rootViewController = context.coordinator.rootViewController()
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(adHeight: $adHeight)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject, BannerViewDelegate {

        @Binding var adHeight: CGFloat

        init(adHeight: Binding<CGFloat>) {
            _adHeight = adHeight
        }

        func rootViewController() -> UIViewController? {
            UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first?.windows
                .first?.rootViewController
        }

        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            DispatchQueue.main.async {
                self.adHeight = bannerView.adSize.size.height
            }
            print("BannerAdView: ad loaded ✅ height: \(bannerView.adSize.size.height)")
        }

        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("BannerAdView: failed to load – \(error.localizedDescription)")
        }
    }
}
