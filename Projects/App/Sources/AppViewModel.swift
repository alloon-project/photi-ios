//
//  AppViewModel.swift
//  DTO
//
//  Created by jung on 6/1/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol AppCoordinatable: AnyObject {
  func shouldReloadAllPage()
  func attachLogIn()
}

protocol AppViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: AppCoordinatable? { get set }
}

final class AppViewModel: AppViewModelType {
  weak var coordinator: AppCoordinatable?
  private let useCase: AppUseCase
  private let disposeBag = DisposeBag()

  private let allowMoveToMyPage = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapMyPageTabBarItem: Signal<Void>
    let didTapLogInButton: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let allowMoveToMyPage: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: AppUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapMyPageTabBarItem
      .emit(with: self) { owner, _ in
        owner.handleMyPageTabSelection()
      }
      .disposed(by: disposeBag)
    
    input.didTapLogInButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachLogIn()
      }
      .disposed(by: disposeBag)
    
    return Output(allowMoveToMyPage: allowMoveToMyPage.asSignal())
  }
}

// MARK: - Private Methods
private extension AppViewModel {
  func handleMyPageTabSelection() {
    Task {
      let isLogin = await useCase.isLogIn()

      isLogin ? allowMoveToMyPage.accept(()) : coordinator?.shouldReloadAllPage()
    }
  }
}
