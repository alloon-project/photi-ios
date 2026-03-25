//
//  BannerAdManager.swift
//  DesignSystem
//
//  Created by Claude on 3/25/25.
//

import GoogleMobileAds

public enum BannerAdManager {
  /// AppDelegate의 `didFinishLaunchingWithOptions`에서 호출하세요.
  public static func configure() {
    MobileAds.shared.start()
  }
}
