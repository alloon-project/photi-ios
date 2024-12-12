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
  private var currentPercent = PhotiProgressPercent.percent0 {
    didSet {
      progressBar.percent = currentPercent
      updateTagViewContraints(percent: currentPercent)
    }
  }
  private let viewModel: FeedViewModel
  private let disposeBag = DisposeBag()
  private var contentOrderType: ContentOrderType = .recent
  private var feeds = [[FeedPresentationModel]]() {
    didSet {
      feedCollectionView.reloadData()
    }
  }

  // MARK: - UI Components
  private let progressBar = MediumProgressBar(percent: .percent0)
  private let orderButton = IconTextButton(text: "최신순", icon: .chevronDownGray700, size: .xSmall)
  private let tagView = TagView(image: .peopleWhite)
  private let feedCollectionView: SelfVerticalSizingCollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumLineSpacing = 10
    layout.minimumInteritemSpacing = 7
    layout.itemSize = .init(width: 160, height: 160)
    layout.sectionHeadersPinToVisibleBounds = true
    
    let collectionView = SelfVerticalSizingCollectionView(layout: layout)
    collectionView.registerCell(FeedCell.self)
    collectionView.registerHeader(FeedCollectionHeaderView.self)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false
    collectionView.isScrollEnabled = false

    return collectionView
  }()
  
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
    feedCollectionView.dataSource = self
    feedCollectionView.delegate = self
  }
}

// MARK: - UI Methods
private extension FeedViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(progressBar, orderButton, feedCollectionView, tagView)
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
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalTo(progressBar.snp.bottom).offset(8)
    }
    
    feedCollectionView.snp.makeConstraints {
      $0.top.equalTo(orderButton.snp.bottom).offset(30)
      $0.centerX.equalToSuperview()
      $0.width.equalTo(327)
      $0.bottom.equalToSuperview()
    }
  }
}

// MARK: - UICollectionViewDataSource
extension FeedViewController: UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return feeds.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return feeds[section].count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(FeedCell.self, for: indexPath)
    cell.configure(with: feeds[indexPath.section][indexPath.row])
    
    return cell
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    viewForSupplementaryElementOfKind kind: String,
    at indexPath: IndexPath
  ) -> UICollectionReusableView {
    guard  kind == UICollectionView.elementKindSectionHeader else {
      return UICollectionReusableView()
    }
      
    let header = collectionView.dequeueHeader(FeedCollectionHeaderView.self, for: indexPath)
    
    /// 테스트용 코드입니다.
    if indexPath.section == 0 {
      header.configure(date: "오늘", type: .didNotProof(deadLine: "18:00까지"))
    } else {
      header.configure(date: "1일 전", type: .none)
    }
    
    return header
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension FeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    referenceSizeForHeaderInSection section: Int
  ) -> CGSize {
    return CGSize(width: collectionView.bounds.width, height: 44)
  }
  
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return .init(top: 8, left: 0, bottom: 18, right: 0)
  }
}

// MARK: - Private Methods
private extension FeedViewController {
  func updateTagViewContraints(percent: PhotiProgressPercent) {
    let tagViewLeading = tagViewLeading(for: percent.rawValue)
    
    UIView.animate(withDuration: 0.4) { [weak self] in
      guard let self else { return }
      tagView.snp.updateConstraints {
        $0.leading.equalToSuperview().offset(tagViewLeading)
      }
      view.layoutIfNeeded()
    }
  }
  
  func tagViewLeading(for progess: Double) -> Double {
    let centerX = progressBar.bounds.width * progess
    let leading: Double = centerX - tagView.frame.width / 2.0

    return leading.bound(lower: 24, upper: progressBar.bounds.width - tagView.frame.width)
  }
}
