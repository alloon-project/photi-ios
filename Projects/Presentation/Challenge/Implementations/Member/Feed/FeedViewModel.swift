//
//  FeedViewModel.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UseCase

enum FeedAlignMode: String, CaseIterable {
  case recent = "최신순"
  case popular = "인기순"
}

protocol FeedCoordinatable: AnyObject {
  func attachFeedDetail(for feedID: String)
  func didChangeContentOffset(_ offset: Double)
}

protocol FeedViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var coordinator: FeedCoordinatable? { get set }
}

final class FeedViewModel: FeedViewModelType {
  weak var coordinator: FeedCoordinatable?
  private let disposeBag = DisposeBag()
  private let challengeId: Int
  private let useCase: ChallengeUseCase
  
  private let isUploadSuccessRelay = PublishRelay<Bool>()
  
  // MARK: - Input
  struct Input {
    let didTapOrderButton: Signal<FeedAlignMode>
    let didTapFeed: Signal<String>
    let contentOffset: Signal<Double>
    let uploadImage: Signal<Data>
  }
  
  // MARK: - Output
  struct Output {
    let isUploadSuccess: Signal<Bool>
  }
  
  // MARK: - Initializers
  init(challengeId: Int, useCase: ChallengeUseCase) {
    self.challengeId = challengeId
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    input.didTapOrderButton
      .emit(with: self) { owner, align in
        // TODO: 서버 연동 후, 구현 예정
        print("didTapOrderButton")
      }
      .disposed(by: disposeBag)
    
    input.didTapFeed
      .emit(with: self) {owner, _ in
        owner.coordinator?.attachFeedDetail(for: "0")
      }
      .disposed(by: disposeBag)
    
    input.contentOffset
      .emit(with: self) {owner, offset in
        owner.coordinator?.didChangeContentOffset(offset)
      }
      .disposed(by: disposeBag)
    
    input.uploadImage
      .emit(with: self) { owner, imageData in
        // TODO: - 서버로 전송
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
