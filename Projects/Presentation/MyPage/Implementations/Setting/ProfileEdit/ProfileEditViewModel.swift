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
import Core
import Entity
import UseCase

protocol ProfileEditCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChangePassword()
  func attachResign()
  func authenticatedFailed()
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
  private let isSuccessedUploadImageRelay = PublishRelay<Bool>()
  private let networkUnstableRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let didTapProfileEditMenu: Signal<ProfileEditMenuItem>
    let didTapResignButton: Signal<Void>
    let requestData: Signal<Void>
    let didSelectImage: Signal<UIImageWrapper>
  }
  
  // MARK: - Output
  struct Output {
    let profileEditMenuItemsRelay: Driver<[ProfileEditMenuItem]>
    let profileImageUrl: Driver<URL?>
    let isSuccessedUploadImage: Signal<Bool>
    let networkUnstable: Signal<Void>
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
    
    input.didSelectImage
      .emit(with: self) { owner, image in
        Task { await owner.updateUserProfile(image) }
      }
      .disposed(by: disposeBag)
    
    input.didTapResignButton
      .emit(with: self) { owner, _ in
        owner.coordinator?.attachResign()
      }
      .disposed(by: disposeBag)
    
    return Output(
      profileEditMenuItemsRelay: profileEditMenuItemsRelay.asDriver(),
      profileImageUrl: profileImageUrlRelay.asDriver(),
      isSuccessedUploadImage: isSuccessedUploadImageRelay.asSignal(),
      networkUnstable: networkUnstableRelay.asSignal()
    )
  }
}

// MARK: - API Methods
private extension ProfileEditViewModel {
  func loadUserProfile() async {
    do {
      let profile = try await useCase.loadUserProfile()
      
      let menuItems: [ProfileEditMenuItem] = [.id(profile.name), .email(profile.email), .editPassword]
      
      profileEditMenuItemsRelay.accept(menuItems)
      profileImageUrlRelay.accept(profile.imageUrl)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func updateUserProfile(_ image: UIImageWrapper) async {
    do {
      let url = try await useCase.updateProfileImage(image)
      profileImageUrlRelay.accept(url)
      isSuccessedUploadImageRelay.accept(true)
    } catch {
      uploadFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.accept(()) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .myPageFailed(reason) where reason == .userNotFound:
        coordinator?.authenticatedFailed()
      default:
        networkUnstableRelay.accept(())
    }
  }
  
  func uploadFailed(with error: Error) {
    guard let error = error as? APIError else { return isSuccessedUploadImageRelay.accept(false) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .myPageFailed(reason) where reason == .userNotFound:
        coordinator?.authenticatedFailed()
      default: isSuccessedUploadImageRelay.accept(false)
    }
  }
}

// MARK: - Private Methods
private extension ProfileEditViewModel {
  func navitate(to item: ProfileEditMenuItem) { }
}
