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

protocol ReportCoordinatable: AnyObject {
  func didTapBackButtonAtReport()
}

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
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapReportButton: ControlEvent<Void>
    let category: Observable<String>
    let content: ControlProperty<String>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtReport()
      }
      .disposed(by: disposeBag)
    
    input.didTapReportButton
      .bind(with: self) { onwer, _ in
        
      }
      .disposed(by: disposeBag)
    return Output()
  }
}

// MARK: - Private Methods
private extension ReportViewModel {
  func requestInquiry(type: String, content: String) {
    
  }
  
  func requestReport(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) {
    
  }
}
