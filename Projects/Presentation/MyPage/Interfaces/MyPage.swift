//
//  MyPage.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator

public protocol MyPageContainable: Containable {
  func coordinator(listener: MyPageListener) -> ViewableCoordinating
}

public protocol MyPageListener: AnyObject {
  func didFinishWithdrawal()
  func authenticatedFailedAtMyPage()
  func didLogOut()
}
