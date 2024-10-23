//
//  SearchCardCell.swift
//  Presentation
//
//  Created by wooseob on 10/18/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import Core

public final class SearchCardCell: UICollectionViewCell {
  typealias ModelType = SearchCardPresentationModel.ModelType

  // MARK: - Properties
  private(set) var model: SearchCardPresentationModel?
  
  // MARK: - UI Components
  private let whiteBackGroundView = {
    let view = UIView()
    view.layer.cornerRadius = 8
    
    view.layer.shadowColor = UIColor(resource: .photiBlack).cgColor
    view.layer.shadowRadius = 8
    view.layer.shadowOpacity = 1
    view.layer.shadowPath = nil
    view.backgroundColor = .white
    return view
  }()
  
  private let challengeImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 8
    
    return imageView
  }()
  
  private let challengeTitleLabel = UILabel()
  private let fisishedDateLabel = UILabel()
  
  private let bottomWhiteView = UIView()
  private let participantStackView = UIStackView()
//  private let
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
   fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Configure Methods
  func configure() {
    setupUI()
  }
}

// MARK: - UI Methods
private extension SearchCardCell {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(whiteBackGroundView)
    
    whiteBackGroundView.addSubviews(challengeImageView,
                                    challengeTitleLabel,
                                    fisishedDateLabel,
                                    bottomWhiteView)
    
    bottomWhiteView.addSubview(participantStackView)
  }
  
  func setConstraints() {
    whiteBackGroundView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    challengeImageView.snp.makeConstraints {
      $0.edges.equalToSuperview().inset(1)
    }
  }
}

//extension Reactive where Base: SearchCardCell {
//  var didTapImage: ControlEvent<Void> {
//    return base.challengeImageView.rx.didTapImage
//  }
//}
