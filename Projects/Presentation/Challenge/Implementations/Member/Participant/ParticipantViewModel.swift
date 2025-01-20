//
//  ParticipantViewModel.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

protocol ParticipantCoordinatable: AnyObject { }

protocol ParticipantViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: ParticipantCoordinatable? { get set }
}

final class ParticipantViewModel: ParticipantViewModelType {
  weak var coordinator: ParticipantCoordinatable?
  private let disposeBag = DisposeBag()

  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
