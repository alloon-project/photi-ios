//
//  RecommendedChallengesViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol RecommendedChallengesCoordinatable: AnyObject {
  func didTapChallenge(challengeId: Int)
}

protocol RecommendedChallengesViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: RecommendedChallengesCoordinatable? { get set }
}

final class RecommendedChallengesViewModel: RecommendedChallengesViewModelType {
  weak var coordinator: RecommendedChallengesCoordinatable?
  
  private let useCase: SearchUseCase
  private let modelMapper: SearchChallengePresentaionModelMapper
  private let disposeBag = DisposeBag()
  private var fetchingHashTagChallengeTask: Task<Void, Never>?
  private var isFetching = false
  private var isLastPage = false
  private var currentPage = 0
  private var selectedHashTag = "전체" {
    didSet {
      guard selectedHashTag != oldValue else { return }
      selectedHashTagDidChange(selectedHashTag)
    }
  }
  
  private let popularChallenges = BehaviorRelay<[ChallengeCardPresentationModel]>(value: [])
  private let hashTagsRelay = BehaviorRelay<[String]>(value: [])
  private let hashTagInitialChallenges = BehaviorRelay<[ChallengeCardPresentationModel]>(value: [])
  private let hashTagChallenges = BehaviorRelay<[ChallengeCardPresentationModel]>(value: [])
  private let networkUnstableRelay = PublishRelay<Void>()

  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
    let requestHashTagChallenge: Signal<Void>
    let didSelectHashTag: Signal<String>
    let didTapChallenge: Signal<Int>
  }
  
  // MARK: - Output
  struct Output {
    let popularChallenges: Driver<[ChallengeCardPresentationModel]>
    let hashTags: Driver<[String]>
    let hashTagInitialChallenges: Driver<[ChallengeCardPresentationModel]>
    let hashTagChallenges: Driver<[ChallengeCardPresentationModel]>
    let networkUnstable: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase) {
    self.useCase = useCase
    self.modelMapper = SearchChallengePresentaionModelMapper()
  }
  
  func transform(input: Input) -> Output {
    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.fetchAllData() }
      }
      .disposed(by: disposeBag)
    
    input.didSelectHashTag
      .emit(with: self) { owner, hashTag in
        owner.selectedHashTag = hashTag
      }
      .disposed(by: disposeBag)
    
    input.requestHashTagChallenge
      .emit(with: self) { owner, _ in
        Task { await owner.fetchHashTagChallenge(hashTag: owner.selectedHashTag) }
      }
      .disposed(by: disposeBag)
    
    input.didTapChallenge
      .emit(with: self) { owner, id in
        owner.coordinator?.didTapChallenge(challengeId: id)
      }
      .disposed(by: disposeBag)

    return Output(
      popularChallenges: popularChallenges.asDriver(),
      hashTags: hashTagsRelay.asDriver(),
      hashTagInitialChallenges: hashTagInitialChallenges.asDriver(),
      hashTagChallenges: hashTagChallenges.asDriver(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - API Methods
private extension RecommendedChallengesViewModel {
  func fetchAllData() async {
    do {
      async let hashtags = fetchHastags()
      async let challenges = fetchPopularChallenges()

      try await popularChallenges.accept(challenges)
      try await hashTagsRelay.accept(hashtags)
    } catch {
      networkUnstableRelay.accept(())
    }
  }
  
  func fetchPopularChallenges() async throws -> [ChallengeCardPresentationModel] {
    let challenges = try await useCase.popularChallenges().value
    return challenges.map {
      modelMapper.mapToChallengeCardPresentationModel(from: $0)
    }
  }
  
  func fetchHastags() async throws -> [String] {
    return try await useCase.popularHashtags().value
  }
  
  func fetchHashTagChallenge(hashTag: String) async {
    guard !Task.isCancelled else { return }
    guard !isLastPage && !isFetching else { return }
    isFetching = true
    
    defer {
      isFetching = false
      currentPage += 1
    }
    
    do {
      try await fetchData()
      guard !Task.isCancelled else { return }
      // 구현 예정
    } catch {
      // 구현 예정
    }
  }
  
  func fetchData() async throws { }
  
  func selectedHashTagDidChange(_ hashTag: String) {
    isLastPage = false
    isFetching = false
    currentPage = 0
    fetchingHashTagChallengeTask?.cancel()
    fetchingHashTagChallengeTask = Task { await fetchHashTagChallenge(hashTag: hashTag) }
    }
}
