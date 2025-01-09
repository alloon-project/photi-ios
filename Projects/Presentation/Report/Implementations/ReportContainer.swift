//
//  ReportContainer.swift
//  LogInImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Report

public protocol ReportDependency: Dependency { }

public final class ReportContainer: Container<ReportDependency>, ReportContainable {
  public func coordinator(listener: ReportListener, reportType: ReportType) -> ViewableCoordinating {
    let viewModel = ReportViewModel()
    let viewControllerable = ReportViewController(viewModel: viewModel, reportType: reportType)
    
    let coordinator = ReportCoordinator(
      viewControllerable: viewControllerable,
      viewModel: viewModel
    )
    coordinator.listener = listener
    return coordinator
  }
}
