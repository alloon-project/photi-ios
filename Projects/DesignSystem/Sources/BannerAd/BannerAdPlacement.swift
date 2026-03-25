//
//  BannerAdPlacement.swift
//  DesignSystem
//

import Foundation

public enum BannerAdPlacement {
  case homeBottom
  case challengeTop
  case myPage

  /// 실제 배포 전 AdMob 콘솔에서 발급받은 광고 단위 ID로 교체하세요.
  /// 현재는 Google 공식 테스트 ID가 설정되어 있습니다.
  var adUnitID: String {
    switch self {
    case .homeBottom:
      return "ca-app-pub-3940256099942544/2934735716"   // TODO: 실제 ID로 교체
    case .challengeTop:
      return "ca-app-pub-3940256099942544/2934735716"   // TODO: 실제 ID로 교체
    case .myPage:
      return "ca-app-pub-3940256099942544/2934735716"   // TODO: 실제 ID로 교체
    }
  }
}
