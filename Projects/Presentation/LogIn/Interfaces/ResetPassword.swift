//
//  ResetPassword.swift
//  LogIn
//
//  Created by jung on 6/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Core

public protocol ResetPasswordContainable: Containable {
  func coordinator(
    userEmail: String,
    userName: String,
    navigation: ViewControllerable,
    listener: ResetPasswordListener
  ) -> Coordinating
}

public protocol ResetPasswordListener: AnyObject {
  func didFinishResetPassword()
  func didCancelResetPassword()
}
