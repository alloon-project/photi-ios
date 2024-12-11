//
//  FeedViewController.swift
//  HomeImpl
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class FeedViewController: UIViewController {
  enum ContentOrderType: String {
    case recent = "최신순"
    case popular = "인기순"
  }
  
  // MARK: - Properties
  private let viewModel: FeedViewModel
  private let disposeBag = DisposeBag()
  private var contentOrderType: ContentOrderType = .recent

  // MARK: - UI Components
  private let progressBar = MediumProgressBar(percent: .percent60)
  private let orderButton = IconTextButton(text: "최신순", icon: .chevronDownGray700, size: .xSmall)
  private let tagView = TagView(image: .peopleWhite)
  private let cardCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
  
  // MARK: - Initializers
  init(viewModel: FeedViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    
    let centerX = progressBar.bounds.width * 0.6
    let leading = centerX - tagView.frame.width / 2
    
    tagView.snp.updateConstraints {
      $0.leading.equalToSuperview().offset(leading)
    }
  }
}

// MARK: - UI Methods
private extension FeedViewController {
  func setupUI() {
    view.backgroundColor = .red100
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(progressBar, orderButton, cardCollectionView, tagView)
  }
  
  func setConstraints() {
    progressBar.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.trailing.equalTo(orderButton.snp.leading).offset(-21)
      $0.height.equalTo(6)
      $0.top.equalToSuperview().offset(24)
    }
    
    orderButton.snp.makeConstraints {
      $0.trailing.equalToSuperview().inset(16)
      $0.centerY.equalTo(progressBar)
    }
    
    tagView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.top.equalTo(progressBar.snp.bottom).offset(8)
    }
    
    cardCollectionView.backgroundColor = .blue100
    cardCollectionView.snp.makeConstraints {
      $0.top.equalTo(orderButton.snp.bottom).offset(30)
      $0.height.equalTo(600)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
}
