//
//  DescriptionViewModel.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Entity
import UseCase

protocol DescriptionCoordinatable: AnyObject { }

protocol DescriptionViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: DescriptionCoordinatable? { get set }
}

final class DescriptionViewModel: DescriptionViewModelType {
  weak var coordinator: DescriptionCoordinatable?
  private let challengeId: Int
  private let useCase: ChallengeUseCase
  private let disposeBag = DisposeBag()
  
  private let description = BehaviorRelay<ChallengeDescription?>(value: nil)
  private let descriptionObservable: Observable<ChallengeDescription>

  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
  }
  
  // MARK: - Output
  struct Output {
    let rules: Driver<[String]>
    let proveTime: Driver<String>
    let goal: Driver<String>
    let duration: Driver<String>
  }
  
  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
    self.descriptionObservable = description.compactMap { $0 }
  }
  
  func transform(input: Input) -> Output {
    input.requestData
      .emit(with: self) { owner, _ in
        owner.fetchDescription()
      }
      .disposed(by: disposeBag)
    
    let proveTime = descriptionObservable.map { $0.proveTime.toString("HH : mm") }
    let duration = descriptionObservable.map {
      "\($0.startDate.toString("yyyy.MM.dd")) ~ \($0.endDate.toString("yyyy-MM-dd"))"
    }
    
    return Output(
      rules: descriptionObservable.map { $0.rules }.asDriver(onErrorJustReturn: []),
      proveTime: proveTime.asDriver(onErrorJustReturn: ""),
      goal: descriptionObservable.map { $0.goal }.asDriver(onErrorJustReturn: ""),
      duration: duration.asDriver(onErrorJustReturn: "")
    )
  }
}

// MARK: - Private Methods
private extension DescriptionViewModel {
  func fetchDescription() {
    useCase.fetchChallengeDescription(id: challengeId)
      .observe(on: MainScheduler.instance)
      .subscribe(with: self) { owner, description in
        owner.description.accept(description)
      } onFailure: { _, _ in
        print("error")
      }
      .disposed(by: disposeBag)
  }
}
