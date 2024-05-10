//
//  AlloonSearchBar.swift
//  DesignSystem
//
//  Created by jung on 5/8/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit
import Core

/// Alloon의 searchBar입니다.
public final class AlloonSearchBar: UISearchBar {
  public override var intrinsicContentSize: CGSize {
    CGSize(width: 296, height: 44)
  }
  
  /// searchBar의 placeholder입니다.
  public override var placeholder: String? {
    didSet {
      self.setPlaceholder(placeholder)
    }
  }
  
  /// searchBar의 text입니다.
  public override var text: String? {
    didSet {
      setText(text)
    }
  }
  
  // MARK: - Initializers
  public init() {
    super.init(frame: .zero)
    setupUI()
  }
  
  public convenience init(placeholder: String, text: String = "") {
    self.init()
    self.placeholder = placeholder
    self.text = text
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - layoutSubviews
  public override func layoutSubviews() {
    super.layoutSubviews()
    searchTextField.clipsToBounds = true
    searchTextField.layer.cornerRadius = intrinsicContentSize.height / 2
  }
  
  // MARK: - Setup UI
  func setupUI() {
    searchBarStyle = .minimal
    searchTextField.backgroundColor = .gray0
   
    searchTextField.snp.remakeConstraints { $0.edges.equalToSuperview() }
    
    let offset = UIOffset(horizontal: -12, vertical: 0)
    setPositionAdjustment(offset, for: .clear)
    setPositionAdjustment(offset, for: .bookmark)
    
    addLeftPadding()
    setBookmarkButton()
    setClearButton()
    setText(text)
    setPlaceholder(placeholder)
  }
}

// MARK: - Private Methods
private extension AlloonSearchBar {
  func addLeftPadding() {
    setImage(nil, for: .search, state: .normal)
    let paddingView = UIView(
      frame: CGRect(x: 0, y: 0, width: 16, height: self.frame.height)
    )
    searchTextField.leftView = paddingView
    searchTextField.leftViewMode = .always
  }
  
  func setClearButton() {
    let image = UIImage(systemName: "xmark.circle.fill")!
    let resizeImage = image.resize(CGSize(width: 24, height: 24)).withTintColor(.gray400)
    setImage(resizeImage, for: .clear, state: .normal)
  }
  
  func setBookmarkButton() {
    self.showsBookmarkButton = true
    let imageColor = UIColor(red: 0.56, green: 0.56, blue: 0.56, alpha: 1)
    
    let image = UIImage(systemName: "magnifyingglass")!
    let resizeImage = image.resize(CGSize(width: 24, height: 24)).withTintColor(imageColor)

    setImage(resizeImage, for: .bookmark, state: .normal)
  }
  
  func setText(_ text: String?) {
    searchTextField.attributedText = (text ?? "").attributedString(
      font: .body2,
      color: .alloonBlack
    )
  }
  
  func setPlaceholder(_ placeholder: String?) {
    searchTextField.attributedPlaceholder = (placeholder ?? "").attributedString(
      font: .body2,
      color: .gray400
    )
  }
}
