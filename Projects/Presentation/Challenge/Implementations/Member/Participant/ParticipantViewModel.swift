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
  func didTapEditButton(userID: Int, challengeID: Int)
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
    let didTapEditButton: Signal<(Int, Int)>
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
      .emit(with: self) { owner, ids in
        owner.coordinator?.didTapEditButton(userID: ids.0, challengeID: ids.1)
      }
      .disposed(by: disposeBag)
    
    return Output()
  }
}
