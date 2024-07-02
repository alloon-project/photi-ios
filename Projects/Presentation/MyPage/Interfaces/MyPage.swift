//
//  MyPage.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

public protocol MyPageContainable: Containable {
  func coordinator(listener: MyPageListener) -> Coordinating
}

public protocol MyPageListener: AnyObject { }
