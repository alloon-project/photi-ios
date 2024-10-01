//
//  Setting.swift
//  MyPage
//
//  Created by 임우섭 on 9/29/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol SettingContainable: Containable {
  func coordinator(listener: SettingListener) -> Coordinating
}

public protocol SettingListener: AnyObject {
  func didTapBackButtonAtSetting()
}
