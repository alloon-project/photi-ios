//
//  WithdrawViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol WithdrawCoordinatable: AnyObject {
  func didTapBackButton()
  func attachWithdrawAuth()
  func didTapCancelButton()
}

protocol WithdrawViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coodinator: WithdrawCoordinatable? { get set }
}

final class WithdrawViewModel: WithdrawViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coodinator: WithdrawCoordinatable?
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapWithdrawButton: ControlEvent<Void>
    let didTapCancelButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { onwer, _ in
        onwer.coodinator?.didTapBackButton()
      }.disposed(by: disposeBag)
    
    input.didTapWithdrawButton
      .bind(with: self) { onwer, _ in
        onwer.coodinator?.attachWithdrawAuth()
      }.disposed(by: disposeBag)
    
    input.didTapCancelButton
      .bind(with: self) { onwer, _ in
        onwer.coodinator?.didTapCancelButton()
      }.disposed(by: disposeBag)
    
    return Output()
  }
}
