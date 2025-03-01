//
//  FeedCommentCell.swift
//  HomeImpl
//
//  Created by jung on 12/15/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core
import DesignSystem

final class FeedCommentCell: UITableViewCell {
  private(set) var id: Int = 0
  var isPressed: Bool = false {
    didSet {
      let alphaComponent: CGFloat = isPressed ? 0.5 : 0.1
      mainContentView.backgroundColor = .white.withAlphaComponent(alphaComponent)
    }
  }
  
  // MARK: - UI Components
  private let mainContentView = UIView()
  private let userNameLabel = UILabel()
  private let commentLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    
    return label
  }()
  
  // MARK: - Initializers
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    selectionStyle = .none
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    mainContentView.backgroundColor = .white.withAlphaComponent(0.1)
    alpha = 1.0
  }
}

// MARK: - Internal Methods
extension FeedCommentCell {
  func configure(model: FeedCommentPresentationModel) {
    self.id = model.commentId
    configureUserName(model.author)
    configureComment(model.content)
  }
}

// MARK: - UI Methods
private extension FeedCommentCell {
  func setupUI() {
    backgroundColor = .clear
    mainContentView.layer.cornerRadius = 10
    setViewHeirarchy()
    setConstraints()
  }
  
  func setViewHeirarchy() {
    contentView.addSubview(mainContentView)
    mainContentView.addSubviews(userNameLabel, commentLabel)
  }
  
  func setConstraints() {
    mainContentView.snp.makeConstraints {
      $0.leading.top.bottom.equalToSuperview()
      $0.trailing.lessThanOrEqualToSuperview()
    }

    userNameLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(10)
      $0.top.equalToSuperview().offset(14)
    }

    userNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
    commentLabel.snp.makeConstraints {
      $0.leading.equalTo(userNameLabel.snp.trailing).offset(8)
      $0.trailing.equalToSuperview().offset(-10)
      $0.top.bottom.equalToSuperview().inset(14)
    }
  }
}

// MARK: - Private Methods
private extension FeedCommentCell {
  func configureUserName(_ userName: String) {
    userNameLabel.attributedText = userName.attributedString(
      font: .body2Bold,
      color: .gray400
    )
  }
  
  func configureComment(_ comment: String) {
    commentLabel.attributedText = comment.attributedString(
      font: .body2,
      color: .gray200
    )
  }
}
