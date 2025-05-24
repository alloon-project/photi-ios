//
//  ChallengeHashtagViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import UseCase

protocol ChallengeHashtagCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeHashtag()
  func didFinishedAtChallengeHashtag(challengeHashtags: [String])
}

protocol ChallengeHashtagViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: ChallengeHashtagCoordinatable? { get set }
}

final class ChallengeHashtagViewModel: ChallengeHashtagViewModelType {
  private let disposeBag = DisposeBag()
  private let useCase: OrganizeUseCase
  
  weak var coordinator: ChallengeHashtagCoordinatable?
      
  // MARK: - Input
  struct Input {
    let didTapBackButton: ControlEvent<Void>
    let enteredHashtag: ControlProperty<String>
    let selectedHashtags: Observable<[String]>
    let didTapNextButton: ControlEvent<Void>
  }
  
  // MARK: - Output
  struct Output {
    let isEnabledAddButton: Observable<Bool>
    let isValidHashtag: Driver<Bool>
    let isEnabledNextButton: Driver<Bool>
  }
  
  // MARK: - Initializers
  init(useCase: OrganizeUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapBackButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtChallengeHashtag()
      }
      .disposed(by: disposeBag)
    
    let isEnabledAddButton = Observable.combineLatest(
      input.enteredHashtag.asObservable(),
      input.selectedHashtags
    ) { enteredHashtag, selectedHashtags in
      !enteredHashtag.isEmpty && enteredHashtag.count <= 6 && selectedHashtags.count < 3
    }
    
    let isHashtagEntered = input.enteredHashtag.map { !$0.isEmpty && $0.count <= 6 }
    
    let isEnabledNextButton = input.selectedHashtags.map { !$0.isEmpty }

    input.didTapNextButton
      .withLatestFrom(input.selectedHashtags)
      .bind(with: self) { owner, hashtags in
        owner.coordinator?.didFinishedAtChallengeHashtag(challengeHashtags: hashtags)
        owner.useCase.configureChallengePayload(.hashtags, value: hashtags)
      }.disposed(by: disposeBag)
    
    return Output(
      isValidHashtag: isHashtagEntered.asDriver(onErrorJustReturn: false),
      isEnabledNextButton: isEnabledNextButton.asDriver(onErrorJustReturn: false)
    )
  }
}
