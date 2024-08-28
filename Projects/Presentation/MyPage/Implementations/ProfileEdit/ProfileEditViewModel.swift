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

protocol ProfileEditCoordinatable: AnyObject {
  func didTapBackButton()
  func attachChangePassword()
}

protocol ProfileEditViewModelType: AnyObject, ProfileEditViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ProfileEditCoordinatable? { get set }
}

final class ProfileEditViewModel: ProfileEditViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ProfileEditCoordinatable?
  
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
        case 0, 1:
          break
        case 2:
          onwer.coordinator?.attachChangePassword()
        default:
          break
        }
      }.disposed(by: disposeBag)
    
    return Output()
  }
}
