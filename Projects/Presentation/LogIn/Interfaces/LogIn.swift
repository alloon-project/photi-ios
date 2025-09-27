//
//  LogIn.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Coordinator

public protocol LogInContainable: Containable {
  func coordinator(listener: LogInListener) -> ViewableCoordinating
}

public protocol LogInListener: AnyObject {
  func didFinishLogIn(userName: String)
  func didTapBackButtonAtLogIn()
}
