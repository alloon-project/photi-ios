//
//  BannerAdView.swift
//  DesignSystem
//

import UIKit
import GoogleMobileAds

public final class BannerAdView: UIView {
  private let bannerView = BannerView(adSize: GADAdSizeBanner)

  // MARK: - Init

  public init(placement: BannerAdPlacement) {
    super.init(frame: .zero)
    bannerView.adUnitID = placement.adUnitID
    setupUI()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Public

  /// ViewController가 화면에 추가된 뒤 호출하세요.
  /// - Parameter viewController: 광고를 표시할 rootViewController
  public func load(from viewController: UIViewController) {
    bannerView.rootViewController = viewController
    bannerView.load(Request())
  }

  public override var intrinsicContentSize: CGSize {
    return CGSize(
      width: bannerView.adSize.size.width,
      height: bannerView.adSize.size.height
    )
  }
}

// MARK: - Private

private extension BannerAdView {
  func setupUI() {
    addSubview(bannerView)
    bannerView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      bannerView.centerXAnchor.constraint(equalTo: centerXAnchor),
      bannerView.centerYAnchor.constraint(equalTo: centerYAnchor)
    ])
  }
}
