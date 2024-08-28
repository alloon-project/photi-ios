//
//  MyPageViewModel.swift
//  MyPageImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol MyPageCoordinatable: AnyObject { 
  func attachSetting()
  func detachSetting()
  func attachAuthCountDetail()
  func detachAuthCountDetail()
}

protocol MyPageViewModelType: AnyObject, MyPageViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: MyPageCoordinatable? { get set }
}

final class MyPageViewModel: MyPageViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: MyPageCoordinatable?
  
  // MARK: - Input
  struct Input {
    let didTapSettingButton: ControlEvent<Void>
    let didTapAuthCountBox: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapSettingButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.attachSetting()
      }.disposed(by: disposeBag)
    
    input.didTapAuthCountBox
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.attachAuthCountDetail()
      }.disposed(by: disposeBag)
    return Output()
  }
}
