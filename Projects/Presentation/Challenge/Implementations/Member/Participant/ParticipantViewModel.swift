//
//  ParticipantViewModel.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift

protocol ParticipantCoordinatable: AnyObject {
  func didChangeContentOffset(_ offset: Double)
  func didTapEditButton(
    challengeID: Int,
    goal: String,
    challengeName: String
  )
}

protocol ParticipantViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ParticipantCoordinatable? { get set }
}

final class ParticipantViewModel: ParticipantViewModelType {
  weak var coordinator: ParticipantCoordinatable?
  private let disposeBag = DisposeBag()

  // MARK: - Input
  struct Input {
    let contentOffset: Signal<Double>
    let didTapEditButton: Signal<(String, Int)>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.contentOffset
      .emit(with: self) { owner, offSet in
        owner.coordinator?.didChangeContentOffset(offSet)
      }
      .disposed(by: disposeBag)
    
    input.didTapEditButton
      .emit(with: self) { owner, info in
        owner.coordinator?.didTapEditButton(
          challengeID: info.1,
          goal: info.0,
          challengeName: "러닝하기"
        )
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}
