//
//  MyMissionContainer.swift
//  MyMissionImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import MyMission

public protocol MyMissionDependency: Dependency { }

public final class MyMissionContainer: Container<MyMissionDependency>, MyMissionContainable {
  public func coordinator(listener: MyMissionListener) -> Coordinating {
    let viewModel = MyMissionViewModel()
    
    let coordinator = MyMissionCoordinator(viewModel: viewModel)
    coordinator.listener = listener
    return coordinator
  }
}
