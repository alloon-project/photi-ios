//
//  RecommendedChallengesViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol RecommendedChallengesCoordinatable: AnyObject { }

protocol RecommendedChallengesViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: RecommendedChallengesCoordinatable? { get set }
}

final class RecommendedChallengesViewModel: RecommendedChallengesViewModelType {
  weak var coordinator: RecommendedChallengesCoordinatable?
  private let disposeBag = DisposeBag()
  
  private let popularChallenges = BehaviorRelay<[ChallengeCardPresentationModel]>(value: [])
  private let hashTagsRelay = BehaviorRelay<[String]>(value: [])
  private let hashTagInitialChallenges = BehaviorRelay<[ChallengeCardPresentationModel]>(value: [])
  private let hashTagChallenges = BehaviorRelay<[ChallengeCardPresentationModel]>(value: [])

  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let popularChallenges: Driver<[ChallengeCardPresentationModel]>
    let hashTags: Driver<[String]>
    let hashTagInitialChallenges: Driver<[ChallengeCardPresentationModel]>
    let hashTagChallenges: Driver<[ChallengeCardPresentationModel]>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.requestData
      .emit(with: self) { owner, _ in
        owner.fetchAllData()
      }
      .disposed(by: disposeBag)
    
    return Output(
      popularChallenges: popularChallenges.asDriver(),
      hashTags: hashTagsRelay.asDriver(),
      hashTagInitialChallenges: hashTagInitialChallenges.asDriver(),
      hashTagChallenges: hashTagChallenges.asDriver()
    )
  }
}

// MARK: - API Methods
private extension RecommendedChallengesViewModel {
  func fetchAllData() {
    fetchPopularChallenges()
    fetchHastags()
  }
  
  func fetchPopularChallenges() { }
  
  func fetchHastags() { }
  
  func fetchHashTagChallenge(hashTag: String) { }
}
