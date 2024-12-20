//
//  FindIdContainer.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol FindIdDependency: Dependency { 
  // 부모에게 요구하는 의존성들을 정의합니다. ex) FindIdUseCase
}

protocol FindIdContainable: Containable {
  func coordinator(listener: FindIdListener) -> Coordinating
}

final class FindIdContainer: Container<FindIdDependency>, FindIdContainable {
  func coordinator(listener: FindIdListener) -> Coordinating {
    let viewModel = FindIdViewModel()
    let coordinator = FindIdCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
