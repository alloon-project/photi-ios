//
//  VerifyEmailContainer.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol VerifyEmailDependency: Dependency {
  // 부모에게 요구하는 의존성들을 정의합니다. ex) FindIdUseCase
}

protocol VerifyEmailContainable: Containable {
  func coordinator(listener: VerifyEmailListener) -> Coordinating
}

final class VerifyEmailContainer: Container<VerifyEmailDependency>, VerifyEmailContainable {
  func coordinator(listener: VerifyEmailListener) -> Coordinating {
    let coordinator = VerifyEmailCoordinator()
    coordinator.listener = listener
    return coordinator
  }
}
