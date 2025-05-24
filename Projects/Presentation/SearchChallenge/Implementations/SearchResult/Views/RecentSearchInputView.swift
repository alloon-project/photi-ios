//
//  RecentSearchInputView.swift
//  HomeImpl
//
//  Created by jung on 5/23/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class RecentSearchInputView: UIView {
  typealias DataSourceType = UICollectionViewDiffableDataSource<Int, String>
  typealias SnapShot = NSDiffableDataSourceSnapshot<Int, String>
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private var datasource: DataSourceType?
  fileprivate let deleteRecentSearchInput = PublishRelay<String>()
  fileprivate let didTapRecentSearchInput = PublishRelay<String>()
  
  // MARK: - UI Components
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "최근 검색어".attributedString(font: .body1Bold, color: .gray900)
    
    return label
  }()
  
  fileprivate let deleteAllButton = TextButton(text: "전체삭제", size: .xSmall, type: .gray)
  private let recentSearchInputCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 10
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.registerCell(RecentSearchInputCell.self)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.automaticallyAdjustsScrollIndicatorInsets = false
    collectionView.contentInsetAdjustmentBehavior = .never
    
    return collectionView
  }()
  
  // MARK: - Initializers
  init() {
    super.init(frame: .zero)
    setupUI()
    bind()
    configureRecentSearchInputCollectionView()
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension RecentSearchInputView {
  func setupUI() {
    self.backgroundColor = .red0
    setViewHeirarchy()
    setConstraints()
  }
  
  func setViewHeirarchy() {
    addSubviews(titleLabel, deleteAllButton, recentSearchInputCollectionView)
  }
  
  func setConstraints() {
    titleLabel.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.centerY.equalTo(deleteAllButton)
    }
    
    deleteAllButton.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.trailing.equalToSuperview().inset(16)
    }
    
    recentSearchInputCollectionView.snp.makeConstraints {
      $0.top.equalTo(deleteAllButton.snp.bottom).offset(12)
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(50)
    }
  }
}

// MARK: - Configure CollectionView
private extension RecentSearchInputView {
  func configureRecentSearchInputCollectionView() {
    let datasource = diffableDataSource()
    self.datasource = datasource
    recentSearchInputCollectionView.dataSource = datasource
    recentSearchInputCollectionView.delegate = self
    initialzeDatasource()
  }
}

// MARK: - Internal Methods
extension RecentSearchInputView {
  func append(searchInputs: [String]) {
    append(items: searchInputs)
  }
}

// MARK: - UICollectionViewDataSource
private extension RecentSearchInputView {
  func diffableDataSource() -> DataSourceType {
    return .init(collectionView: recentSearchInputCollectionView) { [weak self] collectionView, indexPath, input in
      let cell = collectionView.dequeueCell(RecentSearchInputCell.self, for: indexPath)
      cell.configure(with: input)
      self?.bind(cell: cell, input: input)
      
      return cell
    }
  }
  
  func initialzeDatasource() {
    var snapshot = SnapShot()
    snapshot.appendSections([0])
    
    datasource?.apply(snapshot)
  }
  
  func append(items: [String]) {
    guard let datasource else { return }
    var snapshot = datasource.snapshot()
    snapshot.appendItems(items)
    datasource.apply(snapshot)
  }
  
  func delete(item: String) {
    guard let datasource else { return }
    
    var snapshot = datasource.snapshot()
    
    guard let model = snapshot.itemIdentifiers.first(where: { $0 == item }) else { return }
    snapshot.deleteItems([model])
    datasource.apply(snapshot)
  }
  
  func deleteAll() {
    guard let datasource else { return }
    var snapshot = datasource.snapshot()
    snapshot.deleteAllItems()
    datasource.apply(snapshot)
  }
}
// MARK: - UICollectionViewDelegate
extension RecentSearchInputView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let item = datasource?.itemIdentifier(for: indexPath) else { return }
    didTapRecentSearchInput.accept(item)
  }
}

// MARK: - Private Methods
private extension RecentSearchInputView {
  func bind() {
    deleteAllButton.rx.tap
      .bind(with: self) { owner, _ in
        owner.deleteAll()
      }
      .disposed(by: disposeBag)
  }
  
  func bind(cell: RecentSearchInputCell, input: String) {
    cell.rx.didTapDeleteButton
      .bind(with: self) { owner, _ in
        owner.deleteRecentSearchInput.accept(input)
        owner.delete(item: input)
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - Reactive Extension
extension Reactive where Base: RecentSearchInputView {
  var deleteRecentSearchInput: Signal<String> {
    return base.deleteRecentSearchInput.asSignal()
  }
  
  var deleteAllRecentSearchInputs: Signal<Void> {
    return base.deleteAllButton.rx.tap.asSignal()
  }
  
  var didTapRecentSearchInput: Signal<String> {
    return base.didTapRecentSearchInput.asSignal()
  }
}
