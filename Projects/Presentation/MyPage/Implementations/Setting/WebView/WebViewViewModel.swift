//
//  WebViewViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 7/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol WebViewCoordinatable: AnyObject {
}

protocol WebViewViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: WebViewCoordinatable? { get set }
}

final class WebViewViewModel: WebViewViewModelType {
  weak var coordinator: WebViewCoordinatable?
    
  // MARK: - Input
  struct Input {}
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() {}
  
  func transform(input: Input) -> Output {
    return Output()
  }
}

// MARK: - Private Methods
private extension WebViewViewModel {}
