//
//  SplashViewModel.swift
//  Photi-DEV
//
//  Created by jung on 8/14/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import UseCase
import RxCocoa
import RxSwift

protocol SplashListener: AnyObject {
  func didFinishSplash()
}

protocol SplashViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output
}

final class SplashViewModel: SplashViewModelType {
  private let useCase: AppUseCase
  weak var listener: SplashListener?
  
  private let disposeBag = DisposeBag()
  private let requiredForceUpdateRelay = PublishRelay<Void>()
  
  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output {
    let requiredForceUpdate: Signal<Void>
  }
  
  public init(useCase: AppUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    Task { await checkForceUpdate() }
    return Output(requiredForceUpdate: requiredForceUpdateRelay.asSignal())
  }
}

// MARK: - Private Methods
private extension SplashViewModel {
  func checkForceUpdate() async {
    do {
      let isRequired = try await useCase.isAppForceUpdateRequired()

      isRequired ? requiredForceUpdateRelay.accept(()) : await MainActor.run { listener?.didFinishSplash() }
    } catch {
      exit(0)
    }
  }
}
