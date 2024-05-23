//
//  FindIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol FindIdCoordinatable: AnyObject {
  // viewModel에서 coordinator로 전달할 이벤트들을 정의합니다.
}

protocol FindIdViewModelType: AnyObject, FindIdViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: FindIdCoordinatable? { get set }
}

final class FindIdViewModel: FindIdViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: FindIdCoordinatable?
  
  // MARK: - Input
  struct Input { 
    let email: ControlProperty<String>
    let didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
