//
//  EndedChallengeViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol EndedChallengeCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChallenge(id: Int)
  func authenticateFailed()
}

protocol EndedChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: EndedChallengeCoordinatable? { get set }
}

final class EndedChallengeViewModel: EndedChallengeViewModelType {
  weak var coordinator: EndedChallengeCoordinatable?

  private let useCase: MyPageUseCase
  private let disposeBag = DisposeBag()
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0

  private let endedChallengesRelay = BehaviorRelay<[EndedChallengeCardPresentationModel]>(value: [])
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let requestData: Signal<Void>
    let didTapChallenge: Signal<Int>
  }
  
  // MARK: - Output
  struct Output {
    let endedChallenges: Driver<[EndedChallengeCardPresentationModel]>
    let networkUnstable: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)

    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.loadEndedChallenges() }
      }
      .disposed(by: disposeBag)
    
    input.didTapChallenge
      .emit(with: self) { owner, id in
        owner.coordinator?.attachChallenge(id: id)
      }
      .disposed(by: disposeBag)
    
    return Output(
      endedChallenges: endedChallengesRelay.asDriver(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - API Methods
private extension EndedChallengeViewModel {
  func loadEndedChallenges() async {
    guard !isLastPage && !isFetching else { return }
    
    isFetching = true
    
    defer {
      isFetching = false
      currentPage += 1
    }
      
    do {
      let result = try await useCase.loadEndedChallenges(page: currentPage, size: 15)
      let models = result.values.map { mapToEndedPresentationModel($0) }
      endedChallengesRelay.accept(models)
      
      switch result {
        case .lastPage: isLastPage = true
        default: break
      }
    } catch {
      requestFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    if case .authenticationFailed = error {
      coordinator?.authenticateFailed()
    } else {
      networkUnstableRelay.accept(())
    }
  }
}

// MARK: - Private Methods
private extension EndedChallengeViewModel {
  func mapToEndedPresentationModel(_ challenge: ChallengeSummary) -> EndedChallengeCardPresentationModel {
    let deadLine = challenge.endDate.toString("yyyy. MM. dd 종료")
    
    return .init(
      id: challenge.id,
      thumbnailUrl: challenge.imageUrl,
      title: challenge.name,
      deadLine: deadLine,
      currentMemberCnt: challenge.memberCount ?? 0,
      memberImageUrls: challenge.memberImages ?? []
    )
  }
}
