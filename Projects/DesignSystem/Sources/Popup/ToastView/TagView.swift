//
//  TagView.swift
//  DesignSystem
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

public final class TagView: UIView {
  // MARK: - Properties
  public var title: String {
    didSet { setTitle(title) }
  }
  public var image: UIImage? {
    didSet { setImage(image) }
  }
  
  // MARK: - UI Components
  private let contentStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.spacing = 4
    stackView.distribution = .fillProportionally
    stackView.axis = .horizontal
    stackView.alignment = .center
    
    return stackView
  }()
  
  private let imageView = UIImageView()
  private let titleLabel = UILabel()
  
  // MARK: - Initializers
  public init(title: String, image: UIImage?) {
    self.title = title
    self.image = image
    super.init(frame: .zero)
    setupUI()
  }
  
  public convenience init(title: String) {
    self.init(title: title, image: nil)
  }
  
  public convenience init(image: UIImage?) {
    self.init(title: "", image: image)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension TagView {
  func setupUI() {
    backgroundColor = .green400
    layer.cornerRadius = 10
    setViewHierarchy()
    setContraints()
    setTitle(title)
    setImage(image)
  }
  
  func setViewHierarchy() {
    addSubview(contentStackView)
    contentStackView.addArrangedSubviews(imageView, titleLabel)
  }
  
  func setContraints() {
    imageView.snp.makeConstraints {
      $0.width.height.equalTo(16)
    }
    
    contentStackView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(16)
      $0.top.bottom.equalToSuperview().inset(8)
    }
  }
}

// MARK: - Private Methods
private extension TagView {
  func setTitle(_ title: String) {
    titleLabel.attributedText = title.attributedString(
      font: .caption2Bold,
      color: .white
    )
  }
  
  func setImage(_ image: UIImage?) {
    imageView.image = image?.resize(.init(width: 16, height: 16))
  }
}
