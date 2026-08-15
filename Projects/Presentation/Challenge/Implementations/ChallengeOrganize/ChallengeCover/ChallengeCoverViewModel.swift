//
//  ChallengeCoverViewModel.swift
//  Presentation
//
//  Created by 임우섭 on 3/16/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import Foundation
import CoreUI
import Entity
import UseCase

protocol ChallengeCoverCoordinatable: AnyObject {
  func didTapBackButtonAtChallengeCover()
  func didFinishedChallengeCover(coverImage: UIImageWrapper)
}

protocol ChallengeCoverViewModelType: AnyObject {
  associatedtype Input
  associatedtype Output

  var coordinator: ChallengeCoverCoordinatable? { get set }
}

final class ChallengeCoverViewModel: ChallengeCoverViewModelType {
  private var cancellables = Set<AnyCancellable>()
  private let mode: ChallengeOrganizeMode
  private let useCase: OrganizeUseCase

  weak var coordinator: ChallengeCoverCoordinatable?

  private let sampleImagesSubject = PassthroughSubject<[String], Never>()
  private let requestFailedSubject = PassthroughSubject<Void, Never>()
  private let imageSizeErrorSubject = PassthroughSubject<Void, Never>()

  // MARK: - Input
  struct Input {
    let viewDidLoad: AnyPublisher<Void, Never>
    let didTapBackButton: AnyPublisher<Void, Never>
    let challengeCoverImage: AnyPublisher<UIImageWrapper, Never>
    let didTapNextButton: AnyPublisher<Void, Never>
  }

  // MARK: - Output
  struct Output {
    let sampleImages: AnyPublisher<[String], Never>
    let requestFailed: AnyPublisher<Void, Never>
    let imageSizeError: AnyPublisher<Void, Never>
  }

  // MARK: - Initializers
  init(
    mode: ChallengeOrganizeMode,
    useCase: OrganizeUseCase
  ) {
    self.mode = mode
    self.useCase = useCase
  }

  func transform(input: Input) -> Output {
    input.viewDidLoad
      .sinkOnMain(with: self) { owner, _ in
        Task { await owner.fetchCoverImages() }
      }.store(in: &cancellables)

    input.didTapBackButton
      .sinkOnMain(with: self) { owner, _ in
        owner.coordinator?.didTapBackButtonAtChallengeCover()
      }.store(in: &cancellables)

    input.didTapNextButton
      .withLatestFrom(input.challengeCoverImage)
      .sinkOnMain(with: self) { owner, image in
        guard let (data, type) = owner.imageToData(image, maxMB: 8) else {
          owner.imageSizeErrorSubject.send(())
          return
        }
        owner.coordinator?.didFinishedChallengeCover(coverImage: image)
        owner.useCase.configureChallengePayload(.image(data))
        owner.useCase.configureChallengePayload(.imageType(type))
      }.store(in: &cancellables)

    return Output(
      sampleImages: sampleImagesSubject.eraseToAnyPublisher(),
      requestFailed: requestFailedSubject.eraseToAnyPublisher(),
      imageSizeError: imageSizeErrorSubject.eraseToAnyPublisher()
    )
  }
}

// MARK: - Private Methods
private extension ChallengeCoverViewModel {
  func fetchCoverImages() async {
    do {
      let images = try await useCase.fetchChallengeSampleImages()
      sampleImagesSubject.send(images)
    } catch {
      fetchImagesFailed(with: error)
    }
  }

  func fetchImagesFailed(with error: Error) {
    guard let error = error as? APIError else { return }

    switch error {
      default:
        requestFailedSubject.send(())
    }
  }

  func imageToData(_ image: UIImageWrapper, maxMB: Int) -> (image: Data, type: String)? {
    let maxSizeBytes = maxMB * 1024 * 1024

    if let data = image.image.pngData(), data.count <= maxSizeBytes {
      return (data, "png")
    } else if let data = image.image.converToJPEG(maxSizeMB: 8) {
      return (data, "jpeg")
    }
    return nil
  }
}
