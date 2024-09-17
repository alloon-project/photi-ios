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
  public func coordinator(listener: ReportListener, reportData: ReportDataSource) -> Coordinating {
    let viewModel = ReportViewModel()
    let coordinator = ReportCoordinator(viewModel: viewModel, reportData: reportData)
    coordinator.listener = listener
    return coordinator
  }
}
