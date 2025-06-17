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
import Entity
import UseCase
import Report

protocol ReportCoordinatable: AnyObject {
  func didTapBackButtonAtReport()
  func didFinishReport()
}

protocol ReportViewModelType {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ReportCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class ReportViewModel: ReportViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ReportCoordinatable?
  
  private let reportUseCase: ReportUseCase
  private let inquiryUseCase: InquiryUseCase
  private let requestFailedRelay = PublishRelay<Void>()
  let reportType: ReportType
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapReportButton: ControlEvent<Void>
    let reasonAndType: Observable<String> // 신고 이유 및 문의 내용 타입
    let content: ControlProperty<String> // 신고 및 문의 상세내용
  }
  
  // MARK: - Output
  struct Output {
    var requestFailed: Signal<Void>
    var title: String
    var contents: [String]
    var reason: [String]
    var textViewTitle: String
    var textViewPlaceHolder: String
    var buttonTitle: String
  }
  
  // MARK: - Initializers
  init(
    reportUseCase: ReportUseCase,
    inquiryUseCase: InquiryUseCase,
    reportType: ReportType
  ) {
    self.reportUseCase = reportUseCase
    self.inquiryUseCase = inquiryUseCase
    self.reportType = reportType
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtReport()
      }
      .disposed(by: disposeBag)
    
    input.didTapReportButton
      .withLatestFrom(Observable.combineLatest(input.reasonAndType, input.content))
      .bind(with: self) { owner, reasonWithContent in
        switch owner.reportType {
        case .challenge(let id), .member(let id), .feed(let id):
          owner.requestReport(
            category: owner.reportType.category ?? "CHALLENGE",
            reason: reasonWithContent.0,
            content: reasonWithContent.1,
            targetId: id
          )
        case .inquiry:
          owner.requestInquiry(
            type: reasonWithContent.0,
            content: reasonWithContent.1
          )
        }
      }
      .disposed(by: disposeBag)
    
    return Output(
      requestFailed: requestFailedRelay.asSignal(),
      title: reportType.title,
      contents: reportType.contents,
      reason: reportType.reason,
      textViewTitle: reportType.textViewTitle,
      textViewPlaceHolder: reportType.textViewPlaceholder,
      buttonTitle: reportType.buttonTitle
    )
  }
}

// MARK: - Private Methods
private extension ReportViewModel {
  func requestInquiry(type: String, content: String) {
    inquiryUseCase.inquiry(type: type, content: content)
      .observe(on: MainScheduler.instance)
      .subscribe(with: self,
                 onSuccess: { owner, _ in
        owner.coordinator?.didFinishReport()
      }, onFailure: { owner, error in
        owner.requestFailed(with: error)
      }).disposed(by: disposeBag)
  }
  
  func requestReport(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) {
    reportUseCase.report(
      category: category,
      reason: reason,
      content: content,
      targetId: targetId)
    .observe(on: MainScheduler.instance)
    .subscribe(with: self,
               onSuccess: { onwer, _ in
      onwer.coordinator?.didFinishReport()
    }, onFailure: { owner, error in
      owner.requestFailed(with: error)
    }).disposed(by: disposeBag)
  }
  
  func requestFailed(with error: Error) {
    if let error = error as? APIError {
      requestFailedRelay.accept(())
    }
  }
}
