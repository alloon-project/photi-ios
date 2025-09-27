//
//  Report.swift
//  Report
//
//  Created by jung on 7/21/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Coordinator

public protocol ReportContainable: Containable {
  func coordinator(listener: ReportListener, reportType: ReportType) -> ViewableCoordinating
}

public protocol ReportListener: AnyObject { 
  func didTapBackButtonAtReport()
  func didInquiryApplicated()
}
