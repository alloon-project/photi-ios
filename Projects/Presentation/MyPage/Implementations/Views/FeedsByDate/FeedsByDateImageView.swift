//
//  FeedsByDateImageView.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxGesture
import RxSwift
import CoreUI
import DesignSystem

final class FeedsByDateImageView: UIView {
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
  func configure(with url: URL?) {
    imageView.kf.setImage(with: url)
  }
  
  // MARK: - LayoutSubviews
  override func layoutSubviews() {
    super.layoutSubviews()
    roundCorners(leftTop: 10, rightTop: 10, leftBottom: 10, rightBottom: 34)
    configureShapeBorder(width: 6, strockColor: .green200, backGroundColor: .clear)
  }
}

// MARK: - UI Methods
private extension FeedsByDateImageView {
  func setupUI() {
    cornerView.backgroundColor = .green200
    self.backgroundColor = .gray200
    setViewHeirarchy()
    setConstraints()
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

extension Reactive where Base: FeedsByDateImageView {
  var didTapImage: ControlEvent<Void> {
    let observable = base.imageView.rx.tapGesture()
      .when(.recognized)
      .map { _ in }
    return ControlEvent(events: observable)
  }
}
