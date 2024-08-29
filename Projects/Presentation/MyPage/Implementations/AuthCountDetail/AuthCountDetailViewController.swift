//
//  AuthCountDetailViewController.swift
//  MyPageImpl
//
//  Created by wooseob on 8/26/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Core
import DesignSystem

final class AuthCountDetailViewController: UIViewController {
  private let disposeBag = DisposeBag()
  private let itemSpacing: CGFloat = 10
  private let lineSpacing: CGFloat = 16
  
  // MARK: - UIComponents
  private let navigationBar = PrimaryNavigationView(textType: .none,
                                                    iconType: .one,
                                                    colorType: .dark)
  
  private let authCountLabel = {
    let label = UILabel()
    label.attributedText = "총 <highlight>0</highlight>회 인증했어요".htmlEscaped(font: .heading3,
                                                                          textColor: .gray900,
                                                                          highlightTextColor: .green400,
                                                                          lineHeight: 1.6)
    label.textAlignment = .center
    return label
  }()
  
  /// 하단 톱니모양뷰
  private let pinkingImageView = {
    let pinkingView = UIImageView()
    //    pinkingView.image = UIImage(resource: .pinking) TODO: - stencil 추가되면 수정
    pinkingView.backgroundColor = .red // 이미지 영역 표시용 입니다. 추후 삭제 예정.
    pinkingView.clipsToBounds = true
    return pinkingView
  }()
  
  private let historyCollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.registerCell(HistoryCardCell.self)
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = true
    collectionView.contentInset = .zero
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.backgroundColor = .white
    
    return collectionView
  }()
  
  // MARK: - View LifeCycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    historyCollectionView.dataSource = self
    historyCollectionView.collectionViewLayout = collectionViewLayout()
    setupUI()
    bind()
  }
}

// MARK: - Private methods
private extension AuthCountDetailViewController {
  func setupUI() {
    self.view.backgroundColor = .gray100
    setViewHierarchy()
    setConstraints()
  }
  
  func bind() {}
  
  func setViewHierarchy() {
    self.view.addSubviews(navigationBar,
                          authCountLabel,
                          historyCollectionView,
                          pinkingImageView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    authCountLabel.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().offset(-24)
      $0.top.equalTo(navigationBar.snp.bottom).offset(28)
    }
    
    pinkingImageView.snp.makeConstraints {
      $0.leading.equalToSuperview()
      $0.trailing.equalToSuperview()
      $0.top.equalTo(authCountLabel.snp.bottom).offset(46)
      $0.height.equalTo(12)
    }
    
    historyCollectionView.snp.makeConstraints {
      $0.top.equalTo(pinkingImageView)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
}

// MARK: - UICollectionViewDataSource
extension AuthCountDetailViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(HistoryCardCell.self, for: indexPath)
    
    // 샘플이미지 적용
    cell.configure(challangeThumbnail: UIImage(), authDate: Date(), challangeName: "챌린쥐")
    return cell
  }
}

// MARK: - Private Methods
private extension AuthCountDetailViewController {
  func collectionViewLayout() -> UICollectionViewCompositionalLayout {
    let itemFractionalWidthFraction = 1.0 / 2.0 // horizontal 2개의 셀
    let groupFractionalHeightFraction = 1.0 / 2.9 // vertical 2.9개의 셀
    
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(itemFractionalWidthFraction),
      heightDimension: .fractionalHeight(1)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    item.contentInsets = .init(top: 16, leading: 5, bottom: 0, trailing: 5)

    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1),
      heightDimension: .fractionalHeight(groupFractionalHeightFraction)
    )
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    section.contentInsets = .init(top: 19, leading: 19, bottom: 0, trailing: 19)
    
    return UICollectionViewCompositionalLayout(section: section)
  }
}
