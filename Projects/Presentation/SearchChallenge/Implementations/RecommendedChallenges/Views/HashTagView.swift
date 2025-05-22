//
//  HashTagView.swift
//  HomeImpl
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxGesture
import RxSwift
import SnapKit
import Core
import DesignSystem

final class HashTagView: UIView {
  enum Constants {
    static let total = "전체"
  }
  
  private let disposeBag = DisposeBag()
  var hashTags = [String]() {
    didSet { hashTagCollectionView.reloadData() }
  }
  var isSticky: Bool = false {
    didSet { underDashLine.isHidden = !isSticky }
  }
  
  fileprivate var currentSelectedHashTag: String = Constants.total
  
  private var selectedCell: SearchChallengeHashTagCell? {
    didSet { configureSelectedHashTag(current: selectedCell, before: oldValue) }
  }
  
  // MARK: - UI Components
  private let tempChip = TextChip(type: .blue, size: .large)
  private let allChip = TextChip(text: "전체", type: .blue, size: .large)
  private let dividerView = UIView()
  private let underDashLine = DashLineView(lineDashPattern: [4, 4], lineColor: .gray400)

  private let hashTagCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = 8
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.registerCell(SearchChallengeHashTagCell.self)
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
    hashTagCollectionView.dataSource = self
    hashTagCollectionView.delegate = self
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

// MARK: - UI Methods
private extension HashTagView {
  func setupUI() {
    backgroundColor = .white
    underDashLine.isHidden = true
    dividerView.backgroundColor = .blue300
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    addSubviews(allChip, dividerView, hashTagCollectionView, underDashLine)
  }
  
  func setConstraints() {
    allChip.snp.makeConstraints {
      $0.leading.equalToSuperview().inset(24)
      $0.centerY.equalToSuperview()
    }
    
    dividerView.snp.makeConstraints {
      $0.leading.equalTo(allChip.snp.trailing).offset(16)
      $0.centerY.equalToSuperview()
      $0.width.equalTo(1)
      $0.height.equalTo(12)
    }

    hashTagCollectionView.snp.makeConstraints {
      $0.leading.equalTo(dividerView.snp.trailing).offset(16)
      $0.trailing.equalToSuperview()
      $0.centerY.equalToSuperview()
      $0.height.equalTo(50)
    }
    
    underDashLine.snp.makeConstraints {
      $0.leading.trailing.bottom.equalToSuperview()
      $0.height.equalTo(1)
    }
  }
}

// MARK: - Bind Methods
private extension HashTagView {
  func bind() {
    allChip.rx.tapGesture()
      .when(.recognized)
      .bind(with: self) { owner, _ in
        owner.currentSelectedHashTag = Constants.total
        owner.selectedCell = nil
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDataSource
extension HashTagView: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return hashTags.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(SearchChallengeHashTagCell.self, for: indexPath)
    cell.configure(with: hashTags[indexPath.row])
    cell.isSelectedCell = hashTags[indexPath.row] == currentSelectedHashTag
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension HashTagView: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let item = hashTags[indexPath.row]
    let cell = collectionView.cellForItem(at: indexPath)
    
    currentSelectedHashTag = item
    selectedCell = cell as? SearchChallengeHashTagCell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HashTagView: UICollectionViewDelegateFlowLayout {
  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    tempChip.text = hashTags[indexPath.row]
    
   return tempChip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
  }
}

// MARK: - Private Methods
private extension HashTagView {
  func configureSelectedHashTag(current: SearchChallengeHashTagCell?, before: SearchChallengeHashTagCell?) {
    guard current != before else { return }
    
    if before == nil {
      allChip.type = .line
    } else {
      before?.isSelectedCell = false
    }
    
    if current == nil {
      allChip.type = .blue
    } else {
      current?.isSelectedCell = true
    }
  }
}
