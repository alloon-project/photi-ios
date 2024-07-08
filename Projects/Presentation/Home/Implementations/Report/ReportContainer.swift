//
//  ReportContainer.swift
//  LogInImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core

protocol ReportDependency: Dependency {
  // 부모에게 요구하는 의존성들을 정의합니다. ex) ReportUseCase
}

protocol ReportContainable: Containable {
  func coordinator(listener: ReportListener, reportType: ReportType) -> Coordinating
}

final class ReportContainer: Container<ReportDependency>, ReportContainable {
  func coordinator(listener: ReportListener, reportType: ReportType) -> Coordinating {
    let viewModel = ReportViewModel()
    let coordinator = ReportCoordinator(viewModel: viewModel, reportType: reportType)
    coordinator.listener = listener
    return coordinator
  }
}
