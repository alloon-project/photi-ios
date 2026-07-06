//
//  RecommendedChallengesViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import CoreUI
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
  private var cancellables = Set<AnyCancellable>()
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
  
  private let popularChallenges = CurrentValueSubject<[ChallengeCardPresentationModel], Never>([])
  private let hashTagsRelay = CurrentValueSubject<[String], Never>([])
  private let hashTagInitialChallenges = CurrentValueSubject<[ChallengeCardPresentationModel], Never>([])
  private let hashTagChallenges = CurrentValueSubject<[ChallengeCardPresentationModel], Never>([])
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()

  // MARK: - Input
  struct Input {
    let requestData: AnyPublisher<Void, Never>
    let requestHashTagChallenge: AnyPublisher<Void, Never>
    let didSelectHashTag: AnyPublisher<String, Never>
    let didTapChallenge: AnyPublisher<Int, Never>
  }
  
  // MARK: - Output
  struct Output {
    let popularChallenges: AnyPublisher<[ChallengeCardPresentationModel], Never>
    let hashTags: AnyPublisher<[String], Never>
    let hashTagInitialChallenges: AnyPublisher<[ChallengeCardPresentationModel], Never>
    let hashTagChallenges: AnyPublisher<[ChallengeCardPresentationModel], Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase) {
    self.useCase = useCase
    self.modelMapper = SearchChallengePresentaionModelMapper()
  }
  
  func transform(input: Input) -> Output {
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchAllData() }
      }
      .store(in: &cancellables)
    
    input.didSelectHashTag
      .sinkOnMain(with: self) { owner, hashTag in
        owner.selectedHashTag = hashTag
      }
      .store(in: &cancellables)
    
    input.requestHashTagChallenge
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchHashTagChallenge(hashTag: owner.selectedHashTag) }
      }
      .store(in: &cancellables)
    
    input.didTapChallenge
      .sinkOnMain(with: self) { owner, id in
        owner.coordinator?.didTapChallenge(challengeId: id)
      }
      .store(in: &cancellables)

    return Output(
      popularChallenges: popularChallenges.eraseToAnyPublisher(),
      hashTags: hashTagsRelay.eraseToAnyPublisher(),
      hashTagInitialChallenges: hashTagInitialChallenges.eraseToAnyPublisher(),
      hashTagChallenges: hashTagChallenges.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension RecommendedChallengesViewModel {
  func fetchAllData() async {
    Task { await fetchHashTagChallenge(hashTag: selectedHashTag) }

    do {
      async let hashtags = fetchHastags()
      async let challenges = fetchPopularChallenges()

      try await popularChallenges.send(challenges)
      try await hashTagsRelay.send(hashtags)
    } catch {
      networkUnstableRelay.send(())
    }
  }
  
  func fetchPopularChallenges() async throws -> [ChallengeCardPresentationModel] {
    let challenges = try await useCase.popularChallenges()
    return challenges.map {
      modelMapper.mapToChallengeCardFromDetail($0)
    }
  }
  
  func fetchHastags() async throws -> [String] {
    return try await useCase.popularHashtags()
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
      let result = try await useCase.challenges(
        byHashTag: hashTag,
        page: currentPage,
        size: 15
      )
      let models = result.values.map {
        modelMapper.mapToChallengeCardFromSummary($0)
      }

      switch result {
        case .lastPage: isLastPage = true
        default: break
      }
      currentPage == 0 ? hashTagInitialChallenges.send(models) : hashTagChallenges.send(models)
    } catch {
      networkUnstableRelay.send(())
    }
  }
  
  func selectedHashTagDidChange(_ hashTag: String) {
    isLastPage = false
    isFetching = false
    currentPage = 0
    fetchingHashTagChallengeTask?.cancel()
    fetchingHashTagChallengeTask = Task { await fetchHashTagChallenge(hashTag: hashTag) }
  }
}
