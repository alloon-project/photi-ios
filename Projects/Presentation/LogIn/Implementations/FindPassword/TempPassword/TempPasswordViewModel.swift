//
//  TempPasswordViewModel.swift
//  LogInImpl
//
//  Created by wooseob on 6/18/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift
import DesignSystem

protocol TempPasswordCoordinatable: AnyObject {
  // viewModel에서 coordinator로 전달할 이벤트들을 정의합니다.

}

protocol TempPasswordViewModelType: TempPasswordViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: TempPasswordCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class TempPasswordViewModel: TempPasswordViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: TempPasswordCoordinatable?
  
  // MARK: - Input
  struct Input {

  }
  
  // MARK: - Output
  struct Output {

  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    // 단순 동작 bind
   
    // Output 반환
    return Output() // TODO: 서버 연결 후 수정
  }
}
