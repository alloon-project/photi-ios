//
//  ParticipantViewModel.swift
//  Challenge
//
//  Created by jung on 1/20/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import Core
import Entity
import UseCase

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
  private let challengeId: Int
  private let useCase: ChallengeUseCase
  
  private let participants = BehaviorRelay<[ParticipantPresentationModel]>(value: [])

  // MARK: - Input
  struct Input {
    let requestData: Signal<Void>
    let contentOffset: Signal<Double>
    let didTapEditButton: Signal<(String, Int)>
  }
  
  // MARK: - Output
  struct Output {
    let participants: Driver<[ParticipantPresentationModel]>
  }
  
  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.requestData
      .emit(with: self) { owner, _ in
        owner.fetchParticipants()
      }
      .disposed(by: disposeBag)
    
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
    
    return Output(participants: participants.asDriver())
  }
}

// MARK: - Private Methods
private extension ParticipantViewModel {
  func fetchParticipants() {
    useCase.fetchChallengeMembers(challengeId: challengeId)
      .subscribe(with: self) { owner, members in
        let models = members.map { owner.mapToPresentationModel($0) }
        owner.participants.accept(models)
      } onFailure: { _, error in
        print("error!!!:\(error)")
      }
      .disposed(by: disposeBag)
  }
  
  func mapToPresentationModel(_ member: ChallengeMember) -> ParticipantPresentationModel {
    return .init(
      name: member.name,
      avatarURL: member.imageUrl,
      duration: "\(member.duration)일째 활동 중",
      goal: member.goal,
      isChallengeOwner: member.isCreator,
      isSelf: ServiceConfiguration.shared.userName == member.name
    )
  }
}
