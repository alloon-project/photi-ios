//
//  SearchChallengeViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol SearchChallengeCoordinatable: AnyObject {
  func attachChallengeOrganize()
  func didStartSearch()
  func attachChallenge(id: Int)
  func attachNonememberChallenge(id: Int)
  func attachLogin()
}

protocol SearchChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: SearchChallengeCoordinatable? { get set }
}

final class SearchChallengeViewModel: SearchChallengeViewModelType {
  private let useCase: SearchUseCase
  let disposeBag = DisposeBag()
  
  weak var coordinator: SearchChallengeCoordinatable?
  
  private let networkUnstableRelay = PublishRelay<Void>()
  private let exceedMaxChallengeCountRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapChallengeOrganizeButton: ControlEvent<Void>
    let didTapSearchBar: Signal<Void>
    let didTapLogInButton: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let networkUnstable: Signal<Void>
    let exceedMaxChallengeCount: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: SearchUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapChallengeOrganizeButton
      .bind(with: self) { owner, _ in
        owner.handleChallengeOrganizeSelection()
      }.disposed(by: disposeBag)
    
    input.didTapSearchBar
      .emit(with: self) { owner, _ in
        owner.coordinator?.didStartSearch()
      }.disposed(by: disposeBag)
    
    return Output(
      networkUnstable: networkUnstableRelay.asSignal(),
      exceedMaxChallengeCount: exceedMaxChallengeCountRelay.asSignal()
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
      networkUnstableRelay.accept(())
    }
  }
}

// MARK: - Private Methods
private extension SearchChallengeViewModel {
  @MainActor func routeToChallengeOrganizeIfPossible() async {
    let isPossible = await useCase.isPossibleToCreateChallenge()
    
    isPossible ? coordinator?.attachChallengeOrganize() : exceedMaxChallengeCountRelay.accept(())
  }
  
  func handleChallengeOrganizeSelection() {
    Task {
      let isLogin = await useCase.isLogin()

      await isLogin ? routeToChallengeOrganizeIfPossible() : coordinator?.attachLogin()
    }
  }
}
