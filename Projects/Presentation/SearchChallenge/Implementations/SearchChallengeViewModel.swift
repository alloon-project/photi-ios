//
//  SearchChallengeViewModel.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import RxCocoa
import RxSwift

protocol SearchChallengeCoordinatable: AnyObject {
  func didTapChallengeOrganize()
  func didStartSearch()
}

protocol SearchChallengeViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: SearchChallengeCoordinatable? { get set }
}

final class SearchChallengeViewModel: SearchChallengeViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: SearchChallengeCoordinatable?
  
  // MARK: - Input
  struct Input {
    let didTapChallengeOrganizeButton: ControlEvent<Void>
    let didTapSearchBar: Signal<Void>
  }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    input.didTapChallengeOrganizeButton
      .bind(with: self) { owner, _ in
        owner.coordinator?.didTapChallengeOrganize()
      }.disposed(by: disposeBag)
    
    input.didTapSearchBar
      .emit(with: self) { owner, _ in
        owner.coordinator?.didStartSearch()
      }.disposed(by: disposeBag)
    
    return Output()
  }
}
