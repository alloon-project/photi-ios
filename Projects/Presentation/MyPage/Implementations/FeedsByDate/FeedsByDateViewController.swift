//
//  FeedsByDateViewController.swift
//  HomeImpl
//
//  Created by jung on 6/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine
import UIKit
import Coordinator
import SnapKit
import CoreUI
import DesignSystem

final class FeedsByDateViewController: UIViewController, ViewControllerable {
  enum Constants {
    static let groupSpacing: CGFloat = 16
    static let itemLeading: CGFloat = 24
    static let itemTrailing: CGFloat = 45
  }
  
  // MARK: - Properties
  private let viewModel: FeedsByDateViewModel
  private var cancellables = Set<AnyCancellable>()
  private var feeds = [FeedsByDatePresentationModel]() {
    didSet { feedsCollectionView.reloadData() }
  }
  
  private let requestData = PassthroughSubject<Void, Never>()
  private let didTapFeed = PassthroughSubject<(challengeId: Int, feedId: Int), Never>()
  
  // MARK: - UI Components
  private let navigationBar: PhotiNavigationBar
  private let feedsCollectionView: SelfVerticalSizingCollectionView = {
    let collectionView = SelfVerticalSizingCollectionView(layout: UICollectionViewLayout())
    collectionView.registerCell(FeedsByDateCell.self)
    collectionView.decelerationRate = .fast
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.alwaysBounceVertical = false
    
    return collectionView
  }()
  
  // MARK: - Initializers
  init(viewModel: FeedsByDateViewModel) {
    self.viewModel = viewModel
    let dateString = viewModel.date
      .convertTimezone(from: .current, to: .kst)
      .toString("YYYY년 M월 d일")
    
    navigationBar = .init(leftView: .backButton, title: dateString, displayMode: .dark)
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  override func viewDidLoad() {
    super.viewDidLoad()
    
    configureCollectionView()
    setupUI()
    bind()
    
    requestData.send(())
  }
}

// MARK: - UI Methods
private extension FeedsByDateViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
  }
  
  func configureCollectionView() {
    feedsCollectionView.collectionViewLayout = compositionalLayout()
    feedsCollectionView.dataSource = self
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, feedsCollectionView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    feedsCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(navigationBar.snp.bottom).offset(16)
      $0.height.equalTo(feedsCollectionView.snp.width).multipliedBy(0.83)
    }
  }
}

// MARK: - Bind Methods
private extension FeedsByDateViewController {
  func bind() {
    let backButtonEvent = navigationBar.didTapBackButton
    
    let input = FeedsByDateViewModel.Input(
      didTapBackButton: backButtonEvent.eraseToAnyPublisher(),
      requestData: requestData.eraseToAnyPublisher(),
      didTapFeed: didTapFeed.eraseToAnyPublisher()
    )
    let output = viewModel.transform(input: input)
    
    viewModelBind(for: output)
  }
  
  func viewModelBind(for output: FeedsByDateViewModel.Output) {
    output.feeds
      .sinkOnMain(with: self) { owner, feeds in
        owner.feeds = feeds
      }
      .store(in: &cancellables)
    
    output.networkUnstable
      .sinkOnMain(with: self) { owner, _ in
        owner.presentNetworkUnstableAlert()
      }
      .store(in: &cancellables)
  }
  
  func bind(for cell: FeedsByDateCell) {
    cell.didTapFeed
      .sinkOnMain(with: self) { owner, ids in
        owner.didTapFeed.send(ids)
      }
      .store(in: &cancellables)
  }
}

// MARK: - FeedsByDatePresentable
extension FeedsByDateViewController: FeedsByDatePresentable {
  func deleteFeed(challengeId: Int, feedId: Int) {
    feeds.removeAll {
      $0.challengeId == challengeId && $0.feedId == feedId
    }
  }
  
  func deleteAllFeeds(challengeId: Int) {
    feeds.removeAll { $0.challengeId == challengeId }
  }
}

// MARK: - UICollectionView CompositionalLayout
private extension FeedsByDateViewController {
  func compositionalLayout() -> UICollectionViewCompositionalLayout {
    return .init { _, environment in
      let containerWidth = environment.container.effectiveContentSize.width
      let availableWidth = containerWidth - Constants.itemLeading - Constants.itemTrailing
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .fractionalHeight(1)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .absolute(availableWidth),
        heightDimension: .fractionalHeight(1)
      )
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPagingCentered
      section.interGroupSpacing = Constants.groupSpacing
      section.contentInsets = NSDirectionalEdgeInsets(
        top: 0,
        leading: Constants.itemLeading,
        bottom: 0,
        trailing: Constants.itemTrailing
      )
      return section
    }
  }
}

// MARK: -
extension FeedsByDateViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return feeds.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(FeedsByDateCell.self, for: indexPath)
    let isLast = indexPath.row == feeds.count - 1
    cell.configure(with: feeds[indexPath.row], isLast: isLast)
    bind(for: cell)
    return cell
  }
}
