//
//  SearchNavigation.swift
//  DesignSystem
//
//  Created by 임우섭 on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxCocoa
import RxGesture
import RxSwift
import SnapKit
import Core

/// 앱 상단에 들어가는 검색가능한 NavigationView 입니다.
public class SearchNavigation: UIView {
  fileprivate let leftBackButtonImage = {
    var imageView = UIImageView()
    imageView.image = UIImage(resource: .leftBackButtonDark).resize(CGSize(width: 24, height: 24))
    return imageView
  }()
  fileprivate let searchBar: PhotiSearchBar
  
  // MARK: - Initializers
  public init(placeholder: String = "",
              text: String = "") {
    self.searchBar = PhotiSearchBar(placeholder: placeholder, text: text)
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

// MARK: - Reactive Extension
public extension Reactive where Base: SearchNavigation {
  var leftBackButtonDidTap: ControlEvent<Void> {
    let source = base.leftBackButtonImage.rx.tapGesture().when(.recognized).map { _ in }
    return .init(events: source)
  }
  
  var searchButtonDidTap: ControlEvent<Void> {
    return base.searchBar.rx.searchButtonClicked
  }
}
