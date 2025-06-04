//
//  SettingMenuItem.swift
//  MyPageImpl
//
//  Created by jung on 6/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

enum SettingMenuItem {
  case editProfile
  case contactSupport
  case termsOfService
  case privacyPolicy
  case appVersion(version: String)
  case logout
  
  var displayType: SettingMenuDisplayType {
    switch self {
      case .appVersion(let version):
        return .leftSubTitle(title: title, subTitle: version)
      default:
        return .default(title: title)
    }
  }
  
  var title: String {
    switch self {
      case .editProfile: return "프로필 수정"
      case .contactSupport: return "문의하기"
      case .termsOfService: return "서비스 이용약관"
      case .privacyPolicy: return "개인정보 처리방침"
      case .appVersion: return "버전정보"
      case .logout: return "로그아웃"
    }
  }
}

enum SettingMenuDisplayType {
  case `default`(title: String)
  case leftSubTitle(title: String, subTitle: String)
}
