//
//  SettingViewModel.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Combine
import Foundation
import CoreUI
import UseCase

protocol SettingCoordinatable: AnyObject {
  @MainActor func attachProfileEdit()
  @MainActor func attachInquiry()
  func didTapBackButton()
  func didFinishLogOut()
}

protocol SettingViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: SettingCoordinatable? { get set }
}

final class SettingViewModel: SettingViewModelType {
  weak var coordinator: SettingCoordinatable?
  
  private var cancellables = Set<AnyCancellable>()
  private let useCase: MyPageUseCase
  private let settingMenuItems: [SettingMenuItem] = [
    .editProfile,
    .contactSupport,
    .termsOfService,
    .privacyPolicy,
    .appVersion(version: Bundle.appVersion),
    .logout
  ]
  
  private let settingMenuItemsRelay = CurrentValueSubject<[SettingMenuItem], Never>([])
  private let shouldPresentLogoutAlert = PassthroughSubject<Void, Never>()
  private let presentPrivacyPolicy = PassthroughSubject<Void, Never>()
  private let presentServiceTerms = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: AnyPublisher<Void, Never>
    let requestData: AnyPublisher<Void, Never>
    let didTapSettingMenu: AnyPublisher<SettingMenuItem, Never>
    let requestLogOut: AnyPublisher<Void, Never>
  }
  
  // MARK: - Output
  struct Output {
    let settingMenuItems: AnyPublisher<[SettingMenuItem], Never>
    let shouldPresentLogoutAlert: AnyPublisher<Void, Never>
    let presentPrivacyPolicy: AnyPublisher<Void, Never>
    let presentServiceTerms: AnyPublisher<Void, Never>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
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
        owner.settingMenuItemsRelay.send(owner.settingMenuItems)
      }
      .store(in: &cancellables)

    input.didTapSettingMenu
      .sinkOnMain(with: self) { owner, menu in
        Task { await owner.navigate(for: menu) }
      }
      .store(in: &cancellables)
    
    input.requestLogOut
      .sinkOnMain(with: self) { owner, _ in
        owner.requestLogOut()
      }
      .store(in: &cancellables)
    
    return Output(
      settingMenuItems: settingMenuItemsRelay.eraseToAnyPublisher(),
      shouldPresentLogoutAlert: shouldPresentLogoutAlert.eraseToAnyPublisher(),
      presentPrivacyPolicy: presentPrivacyPolicy.eraseToAnyPublisher(),
      presentServiceTerms: presentServiceTerms.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension SettingViewModel {
  @MainActor func navigate(for settingMenu: SettingMenuItem) {
    switch settingMenu {
      case .editProfile: coordinator?.attachProfileEdit()
      case .contactSupport: coordinator?.attachInquiry()
      case .termsOfService: presentServiceTerms.send(())
      case .privacyPolicy: presentPrivacyPolicy.send(())
      case .logout: shouldPresentLogoutAlert.send(())
      default: break
    }
  }
  
  func requestLogOut() {
    useCase.logOut()
    coordinator?.didFinishLogOut()
  }
}
