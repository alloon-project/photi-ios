//
//  ChallengeViewModel.swift
//  ChallengeImpl
//
//  Created by jung on 10/23/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol ChallengeCoordinatable: AnyObject { }

protocol ChallengeViewModelType: AnyObject, ChallengeViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeCoordinatable? { get set }
}

final class ChallengeViewModel: ChallengeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: ChallengeCoordinatable?
  
  private let isUploadSuccessRelay = PublishRelay<Bool>()
  
  // MARK: - Input
  struct Input {
    let uploadImage: Signal<Data>
  }
  
  // MARK: - Output
  struct Output {
    let isUploadSuccess: Signal<Bool>
  }
  
  // MARK: - Initializers
  init(challengeId: Int) { }
  
  func transform(input: Input) -> Output {
    input.uploadImage
      .emit(with: self) { owner, imageData in
        // TODO: - 서버로 전공
        /// 로딩화면을 테스트해보기 위한 테스트 코드입니다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
          if imageData.count % 2 == 0 {
            owner.isUploadSuccessRelay.accept(true)
          } else {
            owner.isUploadSuccessRelay.accept(false)
          }
        }
      }
      .disposed(by: disposeBag)
    
    return Output(isUploadSuccess: isUploadSuccessRelay.asSignal())
  }
}
