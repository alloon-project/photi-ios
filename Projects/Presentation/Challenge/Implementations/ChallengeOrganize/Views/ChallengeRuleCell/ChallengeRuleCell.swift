//
//  ChallengeRuleCell.swift
//  Presentation
//
//  Created by 임우섭 on 4/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import DesignSystem
import RxCocoa
import RxSwift

final class ChallengeRuleCell: UICollectionViewCell {
  // MARK: - Variables
  private let disposeBag = DisposeBag()
  var onTapClose: (() -> Void)?

  // MARK: - UI Components
  private let stackView: UIStackView = {
    let view = UIStackView()
    view.axis = .horizontal
    view.spacing = 6
    view.distribution = .fill

    return view
  }()
  
  private let challengeRuleLabel = {
    let label = UILabel()
    label.numberOfLines = 3
    label.attributedText = "일주일 3회 이상 인증하기".attributedString(
      font: .caption1,
      color: .gray600
    )
    
    return label
  }()
  
  let deleteButton = {
    let button = UIButton()
    button.imageView?.contentMode = .scaleAspectFit
    button.setImage(.closeCircleLight, for: .normal)
    button.setImage(.closeCircleBlue, for: .selected)
    
    button.backgroundColor = .clear
    return button
  }()
  
  // MARK: - Initializers
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
    bind()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    onTapClose = nil
  }
  
  // MARK: - Configure Methods
  func configure(
    with rule: String,
    isSelected: Bool,
    isDefault: Bool
  ) {
    challengeRuleLabel.attributedText = rule.attributedString(
      font: .caption1,
      color: isSelected ? .blue500 : .gray600
    )
    challengeRuleLabel.textAlignment = .center
    self.contentView.backgroundColor = isSelected ? .blue0 : .white
    self.layer.borderColor = isSelected ? UIColor.blue400.cgColor : UIColor.gray200.cgColor
    deleteButton.isSelected = isSelected
    deleteButton.isHidden = (rule == "+" || isDefault)
  }
}

// MARK: - UI Methods
private extension ChallengeRuleCell {
  func setupUI() {
    self.layer.borderWidth = 1
    self.layer.borderColor = UIColor.gray200.cgColor
    self.layer.cornerRadius = 12
    self.contentView.clipsToBounds = true
    self.contentView.layer.cornerRadius = 12
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    contentView.addSubviews(stackView)
    
    stackView.addArrangedSubviews(challengeRuleLabel, deleteButton)
  }
  
  func setConstraints() {
    stackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.bottom.equalToSuperview()
    }
    
    challengeRuleLabel.snp.makeConstraints {
      $0.height.equalToSuperview()
    }
    
    deleteButton.snp.makeConstraints {
      $0.height.width.equalTo(16)
    }
  }
}

// MARK: - Bind Method
private extension ChallengeRuleCell {
  func bind() {
    deleteButton.rx.tap
      .bind { [weak self] in
        self?.onTapClose?()
      }.disposed(by: disposeBag)
  }
}
