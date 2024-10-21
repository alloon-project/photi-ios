//
//  NoneChallengeHomeViewController.swift
//  HomeImpl
//
//  Created by jung on 9/19/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import DesignSystem
import Core

final class NoneChallengeHomeViewController: UIViewController {
  enum Constants {
    static let itemSize = 160.0
    static let groupSpacing = 10.0
  }
  
  // MARK: - Properties
  private let viewModel: NoneChallengeHomeViewModel
  private let disposeBag = DisposeBag()
  private var currentPage = 0
  private var dataSource: [ChallengePresentationModel] = [] {
    didSet {
      challengeImageCollectionView.reloadData()
      configureInformatoinView(for: currentPage)
    }
  }
  
  private let viewWillAppear = PublishRelay<Void>()
  
  // MARK: - UI Components
  private let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .logoLettersBlue
    imageView.contentMode = .left
    
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.attributedText = "photi님의\n열정을 보여주세요!".attributedString(
      font: .heading1,
      color: .gray900
    )
    
    return label
  }()
  
  private let subTitleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "요즘 인기 챌린지 보여드릴게요".attributedString(
      font: .body2,
      color: .gray500
    )
    
    return label
  }()
  
  private let challengeImageCollectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
    collectionView.registerCell(ChallengeImageCell.self)
    collectionView.isPagingEnabled = true
    collectionView.decelerationRate = .fast
    collectionView.alwaysBounceHorizontal = true
    collectionView.alwaysBounceVertical = false
    
    return collectionView
  }()
  
  private let challengeInformationView = ChallengeInformationView()
  private let createChallengeInformationView = CreateChallengeInformationView()
  
  // MARK: - Initalizers
  init(viewModel: NoneChallengeHomeViewModel) {
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
    
    challengeImageCollectionView.collectionViewLayout = compositionalLayout()
    challengeImageCollectionView.dataSource = self
    setupUI()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    viewWillAppear.accept(())
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    
    guard !dataSource.isEmpty else { return }
    scrollToPage(currentPage)
    challengeInformationView.configure(with: dataSource[currentPage])
  }
}

// MARK: - UI Methods
private extension NoneChallengeHomeViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    
    createChallengeInformationView.isHidden = true
  }
  
  func setViewHierarchy() {
    view.addSubviews(logoImageView, titleLabel, subTitleLabel, challengeImageCollectionView)
    view.addSubviews(challengeInformationView, createChallengeInformationView)
  }
  
  func setConstraints() {
    logoImageView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(44)
      $0.trailing.equalToSuperview()
      $0.leading.equalToSuperview().offset(24)
      $0.height.equalTo(56)
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalTo(logoImageView.snp.bottom).offset(24)
      $0.leading.equalToSuperview().offset(24)
    }
    
    subTitleLabel.snp.makeConstraints {
      $0.top.equalTo(titleLabel.snp.bottom).offset(16)
      $0.leading.equalToSuperview().offset(24)
    }
    
    challengeImageCollectionView.snp.makeConstraints {
      $0.top.equalTo(subTitleLabel.snp.bottom).offset(48)
      $0.leading.trailing.equalToSuperview()
      $0.height.equalTo(172)
    }

    challengeInformationView.snp.makeConstraints {
      $0.top.equalTo(challengeImageCollectionView.snp.bottom).offset(24)
      $0.centerX.equalToSuperview()
      $0.height.equalTo(244)
      $0.width.equalTo(327)
    }
    
    createChallengeInformationView.snp.makeConstraints {
      $0.edges.equalTo(challengeInformationView)
    }
  }
}

// MARK: - Bind Methods
private extension NoneChallengeHomeViewController {
  func bind() {
    let input = NoneChallengeHomeViewModel.Input(
      viewWillAppear: viewWillAppear.asSignal()
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: NoneChallengeHomeViewModel.Output) {
    output.challenges
      .drive(with: self) { owner, challenges in
        owner.dataSource = challenges
      }
      .disposed(by: disposeBag)
    
    output.requestFailed
      .emit(with: self) { owner, _ in
        owner.presentWarningPopup()
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - UICollectionViewDataSource
extension NoneChallengeHomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return dataSource.count + 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(ChallengeImageCell.self, for: indexPath)
    
    if indexPath.row == dataSource.count {
      cell.configureCreateCell()
    } else {
      cell.configure(with: dataSource[indexPath.row])
    }
    
    cell.isCurrentPage = indexPath.row == currentPage
    
    return cell
  }
}

// MARK: - Private Methods
private extension NoneChallengeHomeViewController {
  func compositionalLayout() -> UICollectionViewCompositionalLayout {
    return .init { _, _ in
      let itemSize = NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .fractionalHeight(1)
      )
      let item = NSCollectionLayoutItem(layoutSize: itemSize)
      
      let groupSize = NSCollectionLayoutSize(
        widthDimension: .absolute(Constants.itemSize),
        heightDimension: .fractionalHeight(1)
      )
      let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
      
      let section = NSCollectionLayoutSection(group: group)
      section.orthogonalScrollingBehavior = .groupPagingCentered
      section.interGroupSpacing = Constants.groupSpacing
      section.visibleItemsInvalidationHandler = { [weak self] (_, offset, _) in
        guard let self else { return }
        self.offSetDidChange(offset)
      }
      
      return section
    }
  }
  
  func offSetDidChange(_ offset: CGPoint) {
    let page = currentPage(for: offset)
    configureInformatoinView(for: page)
  }
  
  func configureInformatoinView(for page: Int) {
    guard page <= dataSource.count && page >= 0 else { return }
    guard
      let beforeCell = cellForPage(currentPage),
      let currentCell = cellForPage(page)
    else { return }
    
    beforeCell.isCurrentPage = false
    currentCell.isCurrentPage = true
    
    if page == dataSource.count {
      presentCreateChallengeInformationView()
    } else {
      presentChallengeInformationView()
      challengeInformationView.configure(with: dataSource[page])
    }
    
    currentPage = page
  }
  
  func currentPage(for offset: CGPoint) -> Int {
    let emptySpace = (view.frame.width / 2.0) - (Constants.itemSize / 2.0)
    let totalOffset = offset.x + emptySpace
    let minusOffset = (totalOffset / Constants.itemSize) * Constants.groupSpacing
    
    let actualOffSet = totalOffset - minusOffset
    
    return Int(max(0, round(actualOffSet / Constants.itemSize)))
  }
  
  func cellForPage(_ page: Int) -> ChallengeImageCell? {
    let indexPath = IndexPath(row: page, section: 0)
    
    return challengeImageCollectionView.cellForItem(at: indexPath) as? ChallengeImageCell
  }
  
  func scrollToPage(_ page: Int, animated: Bool = false) {
    guard dataSource.count > page else { return }
    let indexPath = IndexPath(row: page, section: 0)
    
    DispatchQueue.main.async {
      self.challengeImageCollectionView.scrollToItem(at: indexPath, at: .top, animated: animated)
    }
  }

  func presentChallengeInformationView() {
    challengeInformationView.isHidden = false
    createChallengeInformationView.isHidden = true
  }

  func presentCreateChallengeInformationView() {
    challengeInformationView.isHidden = true
    createChallengeInformationView.isHidden = false
  }
}
