//
//  SearchNavigation.swift
//  DesignSystem
//
//  Created by 임우섭 on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import SnapKit

public class SearchNavigation: UIView {
  public var leftBackButtonImage = {
    var imageView = UIImageView()
    imageView.image = UIImage(resource: .leftBackButtonDark).resize(CGSize(width: 24, height: 24))
    return imageView
  }()
  public var searchBar: AlloonSearchBar
  
  public init(placeholder: String = "",
              text: String = "") {
    self.searchBar = AlloonSearchBar(placeholder: placeholder, text: text)
    super.init(frame: .zero)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

private extension SearchNavigation {
  // MARK: - Setup UI
  func setupUI() {
    self.addSubviews(leftBackButtonImage, searchBar)
    leftBackButtonImage.snp.makeConstraints {
      $0.width.height.equalTo(32)
      $0.centerY.equalToSuperview()
      $0.leading.equalToSuperview().offset(13)
    }
    
    searchBar.snp.makeConstraints {
      $0.leading.equalTo(leftBackButtonImage.snp.trailing).offset(10)
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalToSuperview().offset(5)
      $0.bottom.equalToSuperview().offset(-5)
    }
  }
}
