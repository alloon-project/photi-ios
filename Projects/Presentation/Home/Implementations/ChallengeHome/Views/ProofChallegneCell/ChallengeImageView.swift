//
//  ChallengeImageView.swift
//  HomeImpl
//
//  Created by jung on 10/7/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
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
    self.type = model
  }
  
  override func layoutSubviews() {
    setupUI(for: type)
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
      case let .proof(image):
        setupDidProofUI(image: image)
      case .didNotProof:
        setupNotProofUI(image: .cameraPlusLightBlue)
    }
    bringSubviewToFront(cornerView)
  }
  
  func setViewHeirarchy() {
    addSubviews(cornerView)
  }
  
  func setConstraints() {
    cornerView.snp.makeConstraints {
      $0.width.height.equalTo(28)
      $0.bottom.trailing.equalToSuperview()
    }
  }
}

// MARK: - Private Methods
private extension ChallengeImageView {
  func setupDidProofUI(image: UIImage) {
    self.roundCorners(leftTop: 10, rightTop: 10, leftBottom: 10, rightBottom: 34)
    configureShapeBorder(width: 6, strockColor: .green200, backGroundColor: .gray100)
    cornerView.backgroundColor = .green200
    
    imageView.image = image
    addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
  }
  
  func setupNotProofUI(image: UIImage) {
    self.roundCorners(leftTop: 10, rightTop: 10, leftBottom: 10, rightBottom: 34)
    configureShapeBorder(width: 6, strockColor: .blue300, backGroundColor: .gray100)
    cornerView.backgroundColor = .blue300
    
    imageView.image = image
    addSubview(imageView)
    imageView.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.width.height.equalTo(45)
    }
  }
}

extension Reactive where Base: ChallengeImageView {
  var didTapImage: ControlEvent<Void> {
    let observable = base.imageView.rx.tapGesture().when(.recognized)
      .map { _ in }
    return ControlEvent(events: observable)
  }
}
