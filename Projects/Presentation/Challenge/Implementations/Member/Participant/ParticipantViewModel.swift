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
    
    return Output()
  }
}
