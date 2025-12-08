//
//  SettingViewModel.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
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
  
  private let disposeBag = DisposeBag()
  private let useCase: MyPageUseCase
  private let settingMenuItems: [SettingMenuItem] = [
    .editProfile,
    .contactSupport,
    .termsOfService,
    .privacyPolicy,
    .appVersion(version: Bundle.appVersion),
    .logout
  ]
  
  private let settingMenuItemsRelay = BehaviorRelay<[SettingMenuItem]>(value: [])
  private let shouldPresentLogoutAlert = PublishRelay<Void>()
  private let presentPrivacyPolicy = PublishRelay<Void>()
  private let presentServiceTerms = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let requestData: Signal<Void>
    let didTapSettingMenu: Signal<SettingMenuItem>
    let requestLogOut: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let settingMenuItems: Driver<[SettingMenuItem]>
    let shouldPresentLogoutAlert: Signal<Void>
    let presentPrivacyPolicy: Signal<Void>
    let presentServiceTerms: Signal<Void>
  }
  
  // MARK: - Initializers
  init(useCase: MyPageUseCase) {
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
        owner.settingMenuItemsRelay.accept(owner.settingMenuItems)
      }
      .disposed(by: disposeBag)

    input.didTapSettingMenu
      .emit(with: self) { owner, menu in
        Task { await owner.navigate(for: menu) }
      }
      .disposed(by: disposeBag)
    
    input.requestLogOut
      .emit(with: self) { owner, _ in
        owner.requestLogOut()
      }
      .disposed(by: disposeBag)
    
    return Output(
      settingMenuItems: settingMenuItemsRelay.asDriver(),
      shouldPresentLogoutAlert: shouldPresentLogoutAlert.asSignal(),
      presentPrivacyPolicy: presentPrivacyPolicy.asSignal(),
      presentServiceTerms: presentServiceTerms.asSignal()
    )
  }
}

// MARK: - Private Methods
private extension SettingViewModel {
  @MainActor func navigate(for settingMenu: SettingMenuItem) {
    switch settingMenu {
      case .editProfile: coordinator?.attachProfileEdit()
      case .contactSupport: coordinator?.attachInquiry()
      case .termsOfService: presentServiceTerms.accept(())
      case .privacyPolicy: presentPrivacyPolicy.accept(())
      case .logout: shouldPresentLogoutAlert.accept(())
      default: break
    }
  }
  
  func requestLogOut() {
    useCase.logOut()
    coordinator?.didFinishLogOut()
  }
}
