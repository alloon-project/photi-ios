//
//  ProfileEditMenuItem.swift
//  MyPageImpl
//
//  Created by jung on 6/4/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

enum ProfileEditMenuItem {
  case id(_ id: String)
  case email(_ email: String)
  case editPassword
  
  var displayType: MenuDisplayType {
    switch self {
      case .id(let id):
        return .leftSubTitle(title: title, subTitle: id)
      case .email(let email):
        return .leftSubTitle(title: title, subTitle: email)
      default:
        return .default(title: title)
    }
  }
  
  var title: String {
    switch self {
      case .id: return "아이디"
      case .email: return "이메일"
      case .editPassword: return "비밀번호 변경"
    }
  }
}
