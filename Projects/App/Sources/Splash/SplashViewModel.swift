//
//  SplashViewModel.swift
//  Photi-DEV
//
//  Created by jung on 8/14/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Combine
import UseCase

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
  
  private let requiredForceUpdateSubject = PassthroughSubject<Void, Never>()
  
  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output {
    let requiredForceUpdate: AnyPublisher<Void, Never>
  }
  
  public init(useCase: AppUseCase) {
    self.useCase = useCase
  }
  
  func transform(input: Input) -> Output {
    Task { await checkForceUpdate() }
    return Output(requiredForceUpdate: requiredForceUpdateSubject.eraseToAnyPublisher())
  }
}

// MARK: - Private Methods
private extension SplashViewModel {
  func checkForceUpdate() async {
    do {
      let isRequired = try await useCase.isAppForceUpdateRequired()

      await MainActor.run {
        isRequired ? requiredForceUpdateSubject.send(()) : listener?.didFinishSplash()
      }
    } catch {
      await MainActor.run { listener?.didFinishSplash() }
    }
  }
}
