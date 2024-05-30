//
//  FindIdViewModel.swift
//  LogInImpl
//
//  Created by jung on 5/20/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import DesignSystem

protocol FindIdCoordinatable: AnyObject {
  // viewModel에서 coordinator로 전달할 이벤트들을 정의합니다.
  func isRequestSucceed()
  func didTapBackButton()
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
    let viewController: UIViewController
    let didTapBackButton: ControlEvent<Void>
    let email: ControlProperty<String>
    let didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
  }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapNextButton
      .withLatestFrom(input.email)
      .bind(with: self) { [weak self] onwer, email in
        self?.requestCheckEmail(email: email) {
          let alertVC = AlertViewController(alertType: .confirm, title: "이메일로 회원정보를 보내드렸어요", subTitle: "다시 로그인해주세요")
          alertVC.present(to: input.viewController, animted: false) {
            onwer.coordinator?.isRequestSucceed()
          }
        }
      }.disposed(by: disposeBag)
        
    input.didTapBackButton
      .bind(with: self) { onwer, _ in
        onwer.coordinator?.didTapBackButton()
      }
      .disposed(by: disposeBag)
    return Output() // TODO: 서버 연결 후 수정
  }
}

// MARK: - Private Methods
private extension FindIdViewModel {
  // TODO: - 서버 연결 후 수정
  func requestCheckEmail(email: String, completion: @escaping () -> Void) {
    // 성공시
    completion()
    // 실패시
    
  }
}
