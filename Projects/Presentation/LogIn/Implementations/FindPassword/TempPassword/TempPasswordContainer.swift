//
//  TempPasswordContainer.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol TempPasswordDependency: Dependency {
  // 부모에게 요구하는 의존성들을 정의합니다. ex) FindIdUseCase
}

protocol TempPasswordContainable: Containable {
  func coordinator(listener: TempPasswordListener, userEmail: String) -> Coordinating
}

final class TempPasswordContainer: Container<TempPasswordDependency>, TempPasswordContainable {
  func coordinator(listener: TempPasswordListener, userEmail: String) -> Coordinating {
    let viewModel = TempPasswordViewModel()
    let coordinator = TempPasswordCoordinator(viewModel: viewModel, userEmail: userEmail)
    coordinator.listener = listener
    return coordinator
  }
}
