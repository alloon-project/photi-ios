//
//  ReportType.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

public struct ReportDataSource {
  public var title: String
  public var contents: [String]
  public var textViewTitle: String
  public var textViewPlaceholder: String
  public var buttonTitle: String
  
  public init(
    title: String,
    contents: [String],
    textViewTitle: String,
    textViewPlaceholder: String,
    buttonTitle: String
  ) {
    self.title = title
    self.contents = contents
    self.textViewTitle = textViewTitle
    self.textViewPlaceholder = textViewPlaceholder
    self.buttonTitle = buttonTitle
  }
}
