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

protocol SettingViewModelType: AnyObject, SettingViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: SettingCoordinatable? { get set }
}

final class SettingViewModel: SettingViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: SettingCoordinatable?
  
  // MARK: - Input
  struct Input { 
    let didTapBackButton: ControlEvent<Void>
    let didTapCell: ControlEvent<IndexPath>
  }
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.didTapBackButton()
      }.disposed(by: disposeBag)
    
    input.didTapCell
      .bind(with: self) { onwer, index in
        switch index.row {
        case 0:
          onwer.coordinator?.attachProfileEdit()
        case 1:
          onwer.coordinator?.attachInquiry()
        case 2:
          onwer.coordinator?.attachServiceTerms()
        case 3:
          onwer.coordinator?.attachPrivacy()
        default:
          break
        }
      }.disposed(by: disposeBag)
    return Output()
  }
}
