//
//  ProfileEditViewModel.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Combine
import Foundation
import CoreUI
import Entity
import UseCase

protocol ProfileEditCoordinatable: AnyObject {
  @MainActor func attachChangePassword(userName: String, userEmail: String)
  @MainActor func attachWithdraw()
  func didTapBackButton()
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
  private var cancellables = Set<AnyCancellable>()
  
  private let profileEditMenuItemsRelay = CurrentValueSubject<[ProfileEditMenuItem], Never>([])
  private let profileImageUrlRelay = CurrentValueSubject<URL?, Never>(nil)
  private let isSuccessedUploadImageRelay = PassthroughSubject<Bool, Never>()
  private let networkUnstableRelay = PassthroughSubject<Void, Never>()
  
  private var userName: String?
  private var userEmail: String?
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let didTapProfileEditMenu: AnyPublisher<ProfileEditMenuItem, Never>
    let didTapWithdrawButton: AnyPublisher<Void, Never>
    let requestData: AnyPublisher<Void, Never>
    let didSelectImage: AnyPublisher<UIImageWrapper, Never>
  }
  
  // MARK: - Output
  struct Output {
    let profileEditMenuItemsRelay: AnyPublisher<[ProfileEditMenuItem], Never>
    let profileImageUrl: AnyPublisher<URL?, Never>
    let isSuccessedUploadImage: AnyPublisher<Bool, Never>
    let networkUnstable: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: ProfileEditUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .store(in: &cancellables)
    
    input.requestData
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.loadUserProfile() }
      }.store(in: &cancellables)
    
    input.didTapProfileEditMenu
      .sinkOnMain(with: self) { owner, item in
        Task { await owner.navigate(to: item) }
      }
      .store(in: &cancellables)
    
    input.didSelectImage
      .sinkOnMain(with: self) { owner, image in
        Task { await owner.updateUserProfile(image) }
      }
      .store(in: &cancellables)
    
    input.didTapWithdrawButton
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.coordinator?.attachWithdraw() }
      }
      .store(in: &cancellables)
    
    return Output(
      profileEditMenuItemsRelay: profileEditMenuItemsRelay.eraseToAnyPublisher(),
      profileImageUrl: profileImageUrlRelay.eraseToAnyPublisher(),
      isSuccessedUploadImage: isSuccessedUploadImageRelay.eraseToAnyPublisher(),
      networkUnstable: networkUnstableRelay.eraseToAnyPublisher()
    )
  }
}

// MARK: - API Methods
private extension ProfileEditViewModel {
  func loadUserProfile() async {
    do {
      let profile = try await useCase.loadUserProfile()
      userName = profile.name
      userEmail = profile.email
      let menuItems: [ProfileEditMenuItem] = [.id(profile.name), .email(profile.email), .editPassword]
      
      profileEditMenuItemsRelay.send(menuItems)
      profileImageUrlRelay.send(profile.imageUrl)
    } catch {
      requestFailed(with: error)
    }
  }
  
  func updateUserProfile(_ image: UIImageWrapper) async {
    do {
      guard
        let (imageData, type) = image.imageToData(maxMB: 8)
      else { throw APIError.myPageFailed(reason: .fileTooLarge) }
      let url = try await useCase.updateProfileImage(imageData, type: type)
      profileImageUrlRelay.send(url)
      isSuccessedUploadImageRelay.send(true)
    } catch {
      uploadFailed(with: error)
    }
  }
  
  func requestFailed(with error: Error) {
    guard let error = error as? APIError else { return networkUnstableRelay.send(()) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .myPageFailed(reason) where reason == .userNotFound:
        coordinator?.authenticatedFailed()
      default:
        networkUnstableRelay.send(())
    }
  }
  
  func uploadFailed(with error: Error) {
    guard let error = error as? APIError else { return isSuccessedUploadImageRelay.send(false) }
    
    switch error {
      case .authenticationFailed:
        coordinator?.authenticatedFailed()
      case let .myPageFailed(reason) where reason == .userNotFound:
        coordinator?.authenticatedFailed()
      default: isSuccessedUploadImageRelay.send(false)
    }
  }
}

// MARK: - Private Methods
private extension ProfileEditViewModel {
  @MainActor func navigate(to item: ProfileEditMenuItem) {
    switch item {
      case .editPassword:
        guard let userName, let userEmail else { return }
        coordinator?.attachChangePassword(userName: userName, userEmail: userEmail)
      default: break
    }
  }
}
