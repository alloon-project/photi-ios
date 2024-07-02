//
//  MyPageContainer.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import MyPage

public protocol MyPageDependency: Dependency { }

public final class MyPageContainer: Container<MyPageDependency>, MyPageContainable {
  public func coordinator(listener: MyPageListener) -> Coordinating {
    let viewModel = MyPageViewModel()
    
    let coordinator = MyPageCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
