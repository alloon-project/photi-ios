//
//  AppContainer.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn
import LogInImpl

final class AppDependency: Dependency { }

protocol AppContainable: Containable {
  func coordinator() -> Coordinating
}

final class AppContainer:
  Container<AppDependency>,
  AppContainable,
  LoggedInDependency,
  LoggedOutDependency,
  LogInDependency {
  func coordinator() -> Coordinating {
    return AppCoordinator(
      loggedInContainer: LoggedInContainer(dependency: self),
      loggedOutContainer: LoggedOutContainer(dependency: self)
    )
  }
  
  lazy var logInContainable: LogInContainable = {
    return LogInContainer(dependency: self)
  }()
}
