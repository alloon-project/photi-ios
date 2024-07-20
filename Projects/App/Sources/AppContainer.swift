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
import MyPage
import MyPageImpl
final class AppDependency: Dependency { }

protocol AppContainable: Containable {
  func coordinator() -> Coordinating
}

final class AppContainer:
  Container<AppDependency>,
  AppContainable,
  MainDependency,
  LogInDependency,
  SignUpDependency,
  MyPageDependency
{
  lazy var myPageContainable: MyPageContainable = {
    return MyPageContainer(dependency: self)
  }()
  
  func coordinator() -> Coordinating {
    return AppCoordinator(
      mainContainer: MainContainer(dependency: self),
      logInContainer: LogInContainer(dependency: self)
    )
  }
  
  lazy var signUpContainable: SignUpContainable = {
    return SignUpContainer(dependency: self)
  }()
}
