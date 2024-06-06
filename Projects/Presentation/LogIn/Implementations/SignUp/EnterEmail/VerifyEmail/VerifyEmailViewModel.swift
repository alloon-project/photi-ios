//
//  VerifyEmailViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/23/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol VerifyEmailCoordinatable: AnyObject { 
  func didTapBackButton()
  func didTapNextButton()
}

protocol VerifyEmailViewModelType: AnyObject, VerifyEmailViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: VerifyEmailCoordinatable? { get set }
}

final class VerifyEmailViewModel: VerifyEmailViewModelType {
  let disposeBag = DisposeBag()
  private var verifyCode: String = ""
  
  weak var coordinator: VerifyEmailCoordinatable?
  
  // MARK: - Input
  struct Input { 
    var viewDidLoad: PublishRelay<Void>
    var didTapBackButton: ControlEvent<Void>
    var didTapResendButton: ControlEvent<Void>
    var didTapNextButton: ControlEvent<Void>
    var verifyCode: ControlProperty<String>
  }
  
  // MARK: - Output
  struct Output { 
    var isEnabledNextButton: Signal<Bool>
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    
    input.didTapNextButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapNextButton()
      }
      .disposed(by: disposeBag)
    
    input.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.requestVerifyCode()
      }
      .disposed(by: disposeBag)
    
    let isEnabledNextButton = input.verifyCode
      .map { $0.count == 4 }
      .asSignal(onErrorJustReturn: false)
    
    return Output(
      isEnabledNextButton: isEnabledNextButton
    )
  }
}

// MARK: - Private Methods
private extension VerifyEmailViewModel {
  func requestVerifyCode() {
    self.verifyCode = ""
    print(#function)
    // 새로운 값으로 verifyCode 갱신
  }
}
