//
//  SignUp.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

public protocol SignUpContainable: Containable {
  func coordinator(navigationControllerable: NavigationControllerable, listener: SignUpListener) -> Coordinating
}

public protocol SignUpListener: AnyObject {
  func didFinishSignUp(userName: String)
  func didTapBackButtonAtSignUp()
}
