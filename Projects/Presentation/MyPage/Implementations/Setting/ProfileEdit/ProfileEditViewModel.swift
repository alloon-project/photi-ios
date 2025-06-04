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
  func didTapBackButton()
  func attachChangePassword()
  func attachResign()
}

protocol ProfileEditViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ProfileEditCoordinatable? { get set }

  func transform(input: Input) -> Output
}

final class ProfileEditViewModel: ProfileEditViewModelType {
  weak var coordinator: ProfileEditCoordinatable?

  private let useCase: ProfileEditUseCase
  private let disposeBag = DisposeBag()
  
  private let profileEditMenuItemsRelay = BehaviorRelay<[ProfileEditMenuItem]>(value: [])
  private let profileImageUrlRelay = BehaviorRelay<URL?>(value: nil)
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let didTapProfileEditMenu: Signal<ProfileEditMenuItem>
    let didTapResignButton: Signal<Void>
    let requestData: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let profileEditMenuItemsRelay: Driver<[ProfileEditMenuItem]>
    let profileImageUrl: Driver<URL?>
  }
  
  // MARK: - Initializers
  init(useCase: ProfileEditUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.requestData
      .emit(with: self) { owner, _ in
        Task { await owner.loadUserProfile() }
      }.disposed(by: disposeBag)
    
    input.didTapProfileEditMenu
      .emit(with: self) { owner, item in
        owner.navitate(to: item)
      }
      .disposed(by: disposeBag)
    
    input.didTapResignButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachResign()
      }
      .disposed(by: disposeBag)
    
    return Output(
      profileEditMenuItemsRelay: profileEditMenuItemsRelay.asDriver(),
      profileImageUrl: profileImageUrlRelay.asDriver()
    )
  }
}

// MARK: - Private Methods
private extension ProfileEditViewModel {
  func loadUserProfile() async {
    do {
      let profile = try await useCase.loadUserProfile()
      
      let menuItems: [ProfileEditMenuItem] = [.id(profile.name), .email(profile.email), .editPassword]
      
      profileEditMenuItemsRelay.accept(menuItems)
      profileImageUrlRelay.accept(profile.imageUrl)
    } catch {
      // TODO: 에러시 UI 구현 예정
      print(error)
    }
  }
  
  func navitate(to item: ProfileEditMenuItem) { }
}
