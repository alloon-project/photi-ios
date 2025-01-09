//
//  Home.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

public protocol HomeContainable: Containable {
  func coordinator(navigationControllerable: NavigationControllerable, listener: HomeListener) -> Coordinating
}

public protocol HomeListener: AnyObject { }
