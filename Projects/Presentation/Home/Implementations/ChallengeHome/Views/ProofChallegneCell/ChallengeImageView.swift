//
//  ChallengeImageView.swift
//  HomeImpl
//
//  Created by jung on 10/7/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxGesture
import RxSwift
import Core
import DesignSystem

final class ChallengeImageView: UIView {
  typealias ModelType = MyChallengeFeedPresentationModel.ModelType
  
  fileprivate var modelType: ModelType = .didNotProof
  
  override var intrinsicContentSize: CGSize {
    return .init(width: 198, height: 198)
  }
  
  // MARK: - UI Components
  private let cornerView: UIView = {
    let view = UIView()
    view.layer.cornerRadius = 8
    return view
  }()
  fileprivate let imageView = UIImageView()
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure(with model: ModelType) {
    self.modelType = model
    setupUI(for: modelType)
  }
  
  override func layoutSubviews() {
    setupUI(for: modelType)
  }
}

// MARK: - UI Methods
private extension ChallengeImageView {
  func setupUI() {
    setViewHeirarchy()
    setConstraints()
  }
  
  func setupUI(for type: ModelType) {
    switch type {
      case let .proof(url):
        setupDidProofUI(url: url)
  
      case .didNotProof:
        setupNotProofUI(image: .cameraPlusLightBlue)
    }
  }
  
  func setViewHeirarchy() {
    addSubviews(cornerView, imageView)
  }
  
  func setConstraints() {
    cornerView.snp.makeConstraints {
      $0.width.height.equalTo(28)
      $0.bottom.trailing.equalToSuperview()
    }
    
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
}

// MARK: - Private Methods
private extension ChallengeImageView {
  func demo() {
    self.roundCorners(leftTop: 10, rightTop: 10, leftBottom: 10, rightBottom: 34)
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func setupDidProofUI(url: URL?) {
    self.roundCorners(leftTop: 10, rightTop: 10, leftBottom: 10, rightBottom: 34)
    configureShapeBorder(width: 6, strockColor: .green200, backGroundColor: .clear)
    cornerView.backgroundColor = .green200
    imageView.kf.setImage(with: url) { [weak self] _ in
      guard let self else { return }
      bringSubviewToFront(cornerView)
    }
    imageView.snp.remakeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func setupNotProofUI(image: UIImage) {
    self.roundCorners(leftTop: 10, rightTop: 10, leftBottom: 10, rightBottom: 34)
    configureShapeBorder(width: 6, strockColor: .blue300, backGroundColor: .gray100)
    cornerView.backgroundColor = .blue300
    bringSubviewToFront(imageView)
    bringSubviewToFront(cornerView)
    imageView.image = image
    imageView.snp.remakeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalTo(45)
    }
  }
}

extension Reactive where Base: ChallengeImageView {
  var didTapImage: ControlEvent<Void> {
    let observable = base.imageView.rx.tapGesture().when(.recognized)
      .filter { _ in base.modelType == .didNotProof }
      .map { _ in }
    return ControlEvent(events: observable)
  }
}
