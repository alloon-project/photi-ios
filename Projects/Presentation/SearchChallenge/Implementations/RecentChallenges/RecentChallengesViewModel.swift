//
//  RecentChallengesViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol RecentChallengesCoordinatable: AnyObject {
  func didTapChallenge(challengeId: Int)
}

protocol RecentChallengesViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: RecentChallengesCoordinatable? { get set }
}

final class RecentChallengesViewModel: RecentChallengesViewModelType {
  weak var coordinator: RecentChallengesCoordinatable?

  private let disposeBag = DisposeBag()
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0
  
  private let initialChallenges = BehaviorRelay<[ChallengeCardPresentationModel]>(value: [])
  private let challenges = BehaviorRelay<[ChallengeCardPresentationModel]>(value: [])

  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
    let didTapChallenge: Signal<Int>
  }
  
  // MARK: - Output
  struct Output {
    let initialChallenges: Driver<[ChallengeCardPresentationModel]>
    let challenges: Driver<[ChallengeCardPresentationModel]>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.fetchChallenges() }
      }
      .disposed(by: disposeBag)
    
    input.didTapChallenge
      .emit(with: self) { owner, id in
        owner.coordinator?.didTapChallenge(challengeId: id)
      }
      .disposed(by: disposeBag)
    
    return Output(
      initialChallenges: initialChallenges.asDriver(),
      challenges: challenges.asDriver()
    )
  }
}

// MARK: - API Methods
private extension RecentChallengesViewModel {
  func fetchChallenges() async {
    guard !isLastPage && !isFetching else { return }
    
    isFetching = true
    
    defer {
      isFetching = false
      currentPage += 1
    }
    
    // TODO: API 호출
  }
}   
