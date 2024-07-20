//
//  LogInContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import LogIn
import MyPage
public protocol LogInDependency: Dependency {
  var signUpContainable: SignUpContainable { get }
  var myPageContainable: MyPageContainable { get }
}

public final class LogInContainer:
  Container<LogInDependency>,
  LogInContainable,
  FindIdDependency,
  FindPasswordDependency{
  public func coordinator(listener: LogInListener) -> Coordinating {
    let findId = FindIdContainer(dependency: self)
    let findPassword = FindPasswordContainer(dependency: self)
    let viewModel = LogInViewModel()
    
    let coordinator = LogInCoordinator(
      viewModel: viewModel,
      signUpContainable: dependency.signUpContainable,
      findIdContainable: findId,
      findPasswordContainable: findPassword,
      myPageContainable: dependency.myPageContainable
    )
    coordinator.listener = listener
    return coordinator
  }
}
