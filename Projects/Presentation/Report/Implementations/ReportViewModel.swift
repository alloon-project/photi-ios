//
//  ReportViewModel.swift
//  HomeImpl
//
//  Created by wooseob on 6/27/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import DesignSystem
import Entity
import UseCase
import Report

protocol ReportCoordinatable: AnyObject {
  func didTapBackButtonAtReport()
  func didFinishReport()
}

protocol ReportViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ReportCoordinatable? { get set }

  func transform(input: Input) -> Output
}

final class ReportViewModel: ReportViewModelType {
  private var cancellables = Set<AnyCancellable>()

  weak var coordinator: ReportCoordinatable?

  private let reportUseCase: ReportUseCase
  private let inquiryUseCase: InquiryUseCase
  private let requestFailedSubject = PassthroughSubject<Void, Never>()
  let reportType: ReportType

  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapReportButton: AnyPublisher<Void, Never>
    let reasonAndType: AnyPublisher<String, Never> // 신고 이유 및 문의 내용 타입
    let content: AnyPublisher<String, Never> // 신고 및 문의 상세내용
  }

  // MARK: - Output
  struct Output {
    let requestFailed: AnyPublisher<Void, Never>
    let title: String
    let contents: [String]
    let reason: [String]
    let textViewTitle: String
    let textViewPlaceHolder: String
    let buttonTitle: String
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
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtReport()
      }
      .store(in: &cancellables)

    input.didTapReportButton
      .combineLatest(input.reasonAndType, input.content)
      .map { ($0.1, $0.2) }
      .sinkOnMain(with: self) { owner, reasonWithContent in
        switch owner.reportType {
        case .challenge(let id), .member(let id), .feed(let id):
          Task {
            await owner.requestReport(
              category: owner.reportType.category ?? "CHALLENGE",
              reason: reasonWithContent.0,
              content: reasonWithContent.1,
              targetId: id
            )
          }
        case .inquiry:
          Task {
            await owner.requestInquiry(
              type: reasonWithContent.0,
              content: reasonWithContent.1
            )
          }
        }
      }
      .store(in: &cancellables)

    return Output(
      requestFailed: requestFailedSubject.eraseToAnyPublisher(),
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
  func requestInquiry(type: String, content: String) async {
    do {
      try await inquiryUseCase.inquiry(type: type, content: content)
      coordinator?.didFinishReport()
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestReport(
    category: String,
    reason: String,
    content: String,
    targetId: Int
  ) async {
    do {
      try await reportUseCase.report(
        category: category,
        reason: reason,
        content: content,
        targetId: targetId
      )
      coordinator?.didFinishReport()
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    if error is APIError {
      requestFailedSubject.send(())
    }
  }
}
