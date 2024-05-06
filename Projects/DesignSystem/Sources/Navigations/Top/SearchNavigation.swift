//
//  SearchNavigation.swift
//  DesignSystem
//
//  Created by 임우섭 on 5/2/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit

public final class SearchNavigationView: UIView {
  public let backButtonAciton: (() -> Void)
  public let leftButton = UIButton(type: .custom)
  public var searchTextField = UITextField()
  public let rightSearchButton = UIButton(type: .custom)
  public let rightDeleteButton = UIButton(type: .custom)
  // MARK: - Initializers
  public init(backButtonAciton: @escaping () -> Void,
              seachAction: @escaping (String?) -> Void,
              searchPlaceholder: String?,
              delegate: UITextFieldDelegate) {
    self.backButtonAciton = backButtonAciton
    self.searchTextField.delegate = delegate
    self.searchTextField.placeholder = searchPlaceholder
    super.init()
    
    self.rightSearchButton.addAction(UIAction { [weak self] _ in
      seachAction(self?.searchTextField.text)}, for: .touchUpInside)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - Private methods
private extension SearchNavigationView {
  func setupUI() {
    // left
    leftButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
    leftButton.addAction(UIAction { [weak self] _ in 
      self?.backButtonAciton()}, for: .touchUpInside)
    self.addSubview(leftButton)
    leftButton.snp.makeConstraints {
      $0.width.height.equalTo(32)
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(13)
    }
    
    // textfield
    rightDeleteButton.addAction(UIAction { [weak self] _ in
      self?.searchTextField.text = nil}, for: .touchUpInside)
    
    switch searchTextField.rightViewMode {
    case .never, .always:
      break
    case .whileEditing:
      searchTextField.rightView = self.rightDeleteButton
    case .unlessEditing:
      searchTextField.rightView = self.rightSearchButton
    @unknown default:
      break
    }
    
    self.addSubview(searchTextField)
    searchTextField.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(55)
      $0.trailing.equalToSuperview().offset(-24)
      $0.height.equalTo(44)
    }
  }
}
