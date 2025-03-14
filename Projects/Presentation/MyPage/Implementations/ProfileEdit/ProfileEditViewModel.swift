//
//  ProfileEditViewModel.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol ProfileEditCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChangePassword()
  func attachResign()
}

protocol ProfileEditViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ProfileEditCoordinatable? { get set }
  
  init(useCase: ProfileEditUseCase)
  
  func transform(input: Input) -> Output
}

final class ProfileEditViewModel: ProfileEditViewModelType {
  private let useCase: ProfileEditUseCase

  let disposeBag = DisposeBag()
  
  weak var coordinator: ProfileEditCoordinatable?
  
  private let userInfoRelay = PublishRelay<UserProfile>()

  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapCell: Driver<Int>
    let didTapResignButton: ControlEvent<Void>
    let isVisible: Observable<Bool>
  }
  
  // MARK: - Output
  struct Output {
    let userInfo: Signal<UserProfile>
  }
  
  // MARK: - Initializers
  init(useCase: ProfileEditUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapCell
      .drive(with: self) { onwer, index in
        switch index {
        case 0, 1:
          break
        case 2:
          onwer.coordinator?.attachChangePassword()
        default:
          break
        }
      }.disposed(by: disposeBag)
    
    input.didTapResignButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.attachResign()
      }.disposed(by: disposeBag)
    
    input.isVisible
      .bind(with: self) { onwer, _ in
        onwer.userInfo()
      }.disposed(by: disposeBag)
    
    return Output(
      userInfo: userInfoRelay.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension ProfileEditViewModel {
  func userInfo() {
    useCase.userInfo()
      .observe(on: MainScheduler.instance)
      .subscribe(
        with: self,
        onSuccess: { onwer, userInfo in
          onwer.userInfoRelay.accept(userInfo)
        }
      )
      .disposed(by: disposeBag)
  }
}
