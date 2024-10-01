//
//  ProfileEditViewModel.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import Entity
import UseCase

protocol ProfileEditCoordinatable: AnyObject {
  func attachChangePassword()
  func attachResign()
}

protocol ProfileEditViewModelType: AnyObject, ProfileEditViewModelable {
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
  
  private var userInfoRelay = PublishRelay<ProfileEditInfo>()
  
  // MARK: - Input
  struct Input {
    let didTapCell: ControlEvent<IndexPath>
    let didTapResignButton: ControlEvent<Void>
    let viewWillAppear: ControlEvent<Bool>
  }
  
  // MARK: - Output
  struct Output {
    let userInfo: Driver<ProfileEditInfo>
  }
  
  // MARK: - Initializers
  init(useCase: ProfileEditUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapCell
      .bind(with: self) { onwer, index in
        switch index.row {
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
    
    input.viewWillAppear
      .bind(with: self) { onwer, isViewAppeared in
        if isViewAppeared {
          onwer.userInfo()
        }
      }.disposed(by: disposeBag)
    
    return Output(
      userInfo: userInfoRelay.asDriver(onErrorJustReturn: .init(imageUrl: "ㅇ", userName: "ㄷ", userEmail: "ㅋ"))
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
