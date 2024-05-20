//
//  LogIn.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

public protocol LogInContainable: Containable {
  func coordinator(listener: LogInListener) -> Coordinating
}

public protocol LogInListener: AnyObject { }
