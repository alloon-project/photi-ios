//
//  RecommendedChallengesViewController.swift
//  SearchChallengeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class RecommendedChallengesViewController: UIViewController, ViewControllerable {
  // MARK: - Properties
  private let viewModel: RecommendedChallengesViewModel
  private let disposeBag = DisposeBag()
  
  // MARK: - UI Components
  private let scrollView = UIScrollView()
  private let contentView = UIView()
  private let popularChallengesHeaderView = SearchChallengeHeaderView(
    image: .fireGray700,
    title: "지금 인기 있는 챌린지"
  )
  private let popularChallengesCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
    layout.itemSize = .init(width: 150, height: 200)
    layout.minimumInteritemSpacing = 12
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.registerCell(ChallengeCardCell.self)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
  }()
  private let dashLineView = DashLineView(lineDashPattern: [4, 4], lineColor: .gray400)
  private let dummyView = UIView()
  
  // MARK: - Initializers
  init(viewModel: RecommendedChallengesViewModel) {
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
    popularChallengesCollectionView.dataSource = self
  }
}

// MARK: - UI Methods
private extension RecommendedChallengesViewController {
  func setupUI() {
    view.backgroundColor = .white
    
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.addSubviews(popularChallengesHeaderView, popularChallengesCollectionView, dashLineView)
    contentView.addSubview(dummyView)
  }
  
  func setConstraints() {
    scrollView.snp.makeConstraints {
      $0.edges.equalToSuperview()
    }
    
    contentView.snp.makeConstraints {
      $0.edges.width.equalToSuperview()
    }
    
    popularChallengesHeaderView.snp.makeConstraints {
      $0.top.leading.equalToSuperview().inset(24)
    }

    popularChallengesCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(popularChallengesHeaderView.snp.bottom).offset(20)
      $0.height.equalTo(200)
    }
    
    dashLineView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(popularChallengesCollectionView.snp.bottom).offset(32)
    }
    dummyView.snp.makeConstraints {
      $0.top.equalTo(dashLineView.snp.bottom)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview()
      $0.height.equalTo(400)
    }
  }
}

// MARK: - Bind Methods
private extension RecommendedChallengesViewController {
  func bind() {
    let input = RecommendedChallengesViewModel.Input()
    let output = viewModel.transform(input: input)
    
    viewBind()
    viewModelBind(for: output)
  }
  
  func viewBind() { }
  
  func viewModelBind(for output: RecommendedChallengesViewModel.Output) { }
}

// MARK: - RecommendedChallengesPresentable
extension RecommendedChallengesViewController: RecommendedChallengesPresentable { }

// MARK: - UICollectionViewDataSource
extension RecommendedChallengesViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    popularChallenges.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(ChallengeCardCell.self, for: indexPath)
    cell.configure(with: popularChallenges[indexPath.row])
    return cell
  }
}
