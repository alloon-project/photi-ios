//
//  ProfileEdit.swift
//  MyPage
//
//  Created by 임우섭 on 9/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol ProfileEditContainable: Containable {
  func coordinator(listener: ProfileEditListener) -> Coordinating
}

public protocol ProfileEditListener: AnyObject {
  func didTapBackButtonAtProfileEdit()
}
