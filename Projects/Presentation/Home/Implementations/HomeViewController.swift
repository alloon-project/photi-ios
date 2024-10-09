//
//  HomeViewController.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit
import DesignSystem
import Core

final class HomeViewController: UIViewController {
  enum Constants {
    static let itemWidth: CGFloat = 288
    static let groupSpacing: CGFloat = 16
  }
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private let viewModel: HomeViewModel
  
  private var dataSources: [ProofChallengePresentationModel] = []
  
  // MARK: - UI Components
  private let navigationBar = PrimaryNavigationView(textType: .logo, iconType: .one, colorType: .blue)
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "인증샷 찍으러 가볼까요?".attributedString(
      font: .heading3,
      color: .photiBlack
    )
    
    return label
  }()
  
  private let proofChallengeCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.registerCell(ProofChallengeCell.self)
    collectionView.decelerationRate = .fast
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    
    return collectionView
  }()
  
  // MARK: - Initializers
  init(viewModel: HomeViewModel) {
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
    
    proofChallengeCollectionView.collectionViewLayout = compositionalLayout()
    proofChallengeCollectionView.delegate = self
    proofChallengeCollectionView.dataSource = self
    setupUI()
  }
}

// MARK: - UI Methods
private extension HomeViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, titleLabel, proofChallengeCollectionView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(24)
    }
    
    proofChallengeCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.height.equalTo(298)
    }
  }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSources.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(ProofChallengeCell.self, for: indexPath)
    let model = dataSources[indexPath.row]
    cell.configure(with: model, isLast: indexPath.row == dataSources.count - 1)
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return .init(width: 288, height: 284)
  }
}

// MARK: - Private Methods
private extension HomeViewController {
  func compositionalLayout() -> UICollectionViewCompositionalLayout {
    return .init { _, _ in
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .fractionalHeight(1)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .absolute(Constants.itemWidth),
        heightDimension: .fractionalHeight(1)
      )
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPagingCentered
      section.interGroupSpacing = Constants.groupSpacing
      
      return section
    }
  }
}
