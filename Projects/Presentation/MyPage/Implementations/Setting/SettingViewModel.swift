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

protocol SettingCoordinatable: AnyObject { }

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
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
