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
import Core

protocol SettingCoordinatable: AnyObject {
  func didTapBackButton()
  func attachProfileEdit()
  func detachProfileEdit()
  func attachInquiry()
  func detachInquiry()
  func attachServiceTerms()
  func detachServiceTerms()
  func attachPrivacy()
  func detachPrivacy()
}

protocol SettingViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: SettingCoordinatable? { get set }
}

final class SettingViewModel: SettingViewModelType {
  weak var coordinator: SettingCoordinatable?
  
  private let disposeBag = DisposeBag()
  private let settingMenuItems: [SettingMenuItem] = [
    .editProfile,
    .contactSupport,
    .termsOfService,
    .privacyPolicy,
    .appVersion(version: Bundle.appVersion),
    .logout
  ]
  
  private let settingMenuItemsRelay = BehaviorRelay<[SettingMenuItem]>(value: [])
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: Signal<Void>
    let requestData: Signal<Void>
    let didTapSettingMenu: Signal<SettingMenuItem>
  }
  
  // MARK: - Output
  struct Output {
    let settingMenuItems: Driver<[SettingMenuItem]>
  }
  
  // MARK: - Initializers
  init() { }
  
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
        owner.navigate(for: menu)
      }
      .disposed(by: disposeBag)
    return Output(settingMenuItems: settingMenuItemsRelay.asDriver())
  }
}

// MARK: - Private Methods
private extension SettingViewModel {
  func navigate(for settingMenu: SettingMenuItem) {
    switch settingMenu {
      case .editProfile: coordinator?.attachProfileEdit()
      case .contactSupport: coordinator?.attachInquiry()
      case .termsOfService: coordinator?.attachServiceTerms()
      case .privacyPolicy: coordinator?.attachPrivacy()
      case .logout: requestLogOut()
      default: break
    }
  }
  
  func requestLogOut() { }
}
