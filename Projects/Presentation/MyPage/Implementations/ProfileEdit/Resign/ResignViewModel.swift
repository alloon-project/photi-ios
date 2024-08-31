//
//  ResignViewModel.swift
//  MyPageImpl
//
//  Created by wooseob on 8/30/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ResignCoordinatable: AnyObject {
  func didTapBackButton()
  func attachPasswordAuth()
  func didTapCancelButton()
}

protocol ResignViewModelType: AnyObject, ResignViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coodinator: ResignCoordinatable? { get set }
}

final class ResignViewModel: ResignViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coodinator: ResignCoordinatable?
  
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let didTapResginButton: ControlEvent<Void>
    let didTapCancelButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {}
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { onwer, _ in
        onwer.coodinator?.didTapBackButton()
      }.disposed(by: disposeBag)
    
    input.didTapResginButton
      .bind(with: self) { onwer, _ in
        onwer.coodinator?.attachPasswordAuth()
      }.disposed(by: disposeBag)
    
    input.didTapCancelButton
      .bind(with: self) { onwer, _ in
        onwer.coodinator?.didTapCancelButton()
      }.disposed(by: disposeBag)
    
    return Output()
  }
}
