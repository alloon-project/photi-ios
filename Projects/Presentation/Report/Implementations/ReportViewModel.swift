//
//  ReportViewModel.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import DesignSystem

protocol ReportCoordinatable: AnyObject { }

protocol ReportViewModelType: ReportViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ReportCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class ReportViewModel: ReportViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ReportCoordinatable?
  
  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}