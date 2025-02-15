//
//  ReportCoordinator.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import Report

protocol ReportPresentable { }

final class ReportCoordinator: ViewableCoordinator<ReportPresentable> {
  weak var listener: ReportListener?
  
  private let viewModel: ReportViewModel
  
  init(
    viewControllerable: ViewControllerable,
    viewModel: ReportViewModel
  ) {
    self.viewModel = viewModel
    
    super.init(viewControllerable)
    viewModel.coordinator = self
  }
}

// MARK: - ReportCoordinatable
extension ReportCoordinator: ReportCoordinatable {
  func didFinishReport() {
    listener?.detachReport()
  }
  
  func didTapBackButtonAtReport() {
    listener?.detachReport()
  }
}
