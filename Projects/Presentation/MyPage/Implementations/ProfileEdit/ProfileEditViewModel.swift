//
//  ProfileEditViewModel.swift
//  MyPageImpl
//
//  Created by 임우섭 on 8/4/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ProfileEditCoordinatable: AnyObject { }

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
  struct Input {}
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
