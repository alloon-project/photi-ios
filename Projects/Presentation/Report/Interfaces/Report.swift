//
//  Report.swift
//  Report
//
//  Created by jung on 7/21/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Core

public protocol ReportContainable: Containable {
  func coordinator(listener: ReportListener, reportType: ReportType) -> ViewableCoordinating
}

public protocol ReportListener: AnyObject { 
  func detachReport()
}
