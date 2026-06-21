//
//  SearchChallengeViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Combine
import CoreUI
import Entity
import UseCase

protocol SearchChallengeCoordinatable: AnyObject {
  @MainActor func attachChallengeOrganize()
  @MainActor func attachChallenge(id: Int)
  @MainActor func attachNonememberChallenge(id: Int)
  @MainActor func attachLogin()
  func didStartSearch()
}

protocol SearchChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var cancellables: Set<AnyCancellable> { get set }
  var coordinator: SearchChallengeCoordinatable? { get set }
}

final class SearchChallengeViewModel: SearchChallengeViewModelType {
  private let useCase: SearchUseCase
  private var cancellables = Set<AnyCancellable>()
  
  weak var coordinator: SearchChallengeCoordinatable?
  
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  private let exceedMaxChallengeCountRelay = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapChallengeOrganizeButton: AnyPublisher<Void, Never>
    let didTapSearchBar: AnyPublisher<Void, Never>
    let didTapLogInButton: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let networkUnstable: AnyPublisher<Void, Never>
    let exceedMaxChallengeCount: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapChallengeOrganizeButton
      .sinkOnMain(with: self) { owner, _ in
        owner.handleChallengeOrganizeSelection()
      }.store(in: &cancellables)
    
    input.didTapSearchBar
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didStartSearch()
      }.store(in: &cancellables)
    
    return Output(
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher(),
      exceedMaxChallengeCount: exceedMaxChallengeCountRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - Internal Methods
extension SearchChallengeViewModel {
  @MainActor func decideRouteForChallenge(id: Int) async {
    do {
      let didJoined = try await useCase.didJoinedChallenge(id: id)
      
      didJoined ? coordinator?.attachChallenge(id: id) : coordinator?.attachNonememberChallenge(id: id)
    } catch {
      networkUnstableRelay.send(())
    }
  }
}

// MARK: - Private Methods
private extension SearchChallengeViewModel {
  @MainActor func routeToChallengeOrganizeIfPossible() async {
    let isPossible = await useCase.isPossibleToCreateChallenge()
    
    isPossible ? coordinator?.attachChallengeOrganize() : exceedMaxChallengeCountRelay.send(())
  }
  
  func handleChallengeOrganizeSelection() {
    Task {
      let isLogin = await useCase.isLogin()

      await isLogin ? routeToChallengeOrganizeIfPossible() : coordinator?.attachLogin()
    }
  }
}
