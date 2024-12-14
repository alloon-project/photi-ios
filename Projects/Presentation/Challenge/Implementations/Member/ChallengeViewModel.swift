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
  
  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init(challengeId: Int) { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
