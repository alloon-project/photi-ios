//
//  AppContainer.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

final class AppDependency: Dependency { }

protocol AppContainable: Containable {
  func coordinate() -> Coordinater
}

final class AppContainer:
  Container<AppDependency>,
  AppContainable,
  LoggedInDependency {
  func coordinate() -> Coordinater {
    return AppCoordinator(
      loggedInContainer: LoggedInContainer(dependency: self)
    )
  }
}
