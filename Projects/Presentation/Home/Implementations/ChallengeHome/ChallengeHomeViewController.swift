//
//  ChallengeHomeViewController.swift
//  HomeImpl
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SnapKit
import DesignSystem
import Core

final class ChallengeHomeViewController: UIViewController, CameraRequestable, ViewControllerable {
  enum Constants {
    static let groupSpacing: CGFloat = 16
    static let itemLeading: CGFloat = 24
    static let itemTrailing: CGFloat = 45
  }
  
  typealias MyChallengeFeedDataSourceType = UICollectionViewDiffableDataSource<Int, MyChallengeFeedPresentationModel>
  typealias SnapShot = NSDiffableDataSourceSnapshot<Int, MyChallengeFeedPresentationModel>
  
  // MARK: - Properties
  private var uploadChallengeId: Int = 0
  private var datasource: MyChallengeFeedDataSourceType?
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeHomeViewModel
  
  private let requestData = PublishRelay<Void>()
  private let uploadChallengeFeed = PublishRelay<(Int, UIImageWrapper)>()
  private let didTapLoginButton = PublishRelay<Void>()
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .logo, displayMode: .dark)
  private let scrollView = UIScrollView()
  private let scrollContentView = UIView()
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "인증샷 찍으러 가볼까요?".attributedString(
      font: .heading3,
      color: .photiBlack
    )
    
    return label
  }()
  
  private let proofChallengeCollectionView: SelfVerticalSizingCollectionView = {
    let collectionView = SelfVerticalSizingCollectionView(layout: UICollectionViewLayout())
    collectionView.registerCell(ProofChallengeCell.self)
    collectionView.decelerationRate = .fast
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.alwaysBounceVertical = false
    
    return collectionView
  }()
  
  private let bottomView = HomeBottomView()
  
  // MARK: - Initializers
  init(viewModel: ChallengeHomeViewModel) {
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
    let dataSource = diffableDataSource()
    proofChallengeCollectionView.dataSource = dataSource
    self.datasource = dataSource
    setupUI()
    bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    requestData.accept(())
  }
}

// MARK: - UI Methods
private extension ChallengeHomeViewController {
  func setupUI() {
    scrollView.showsVerticalScrollIndicator = false
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    view.addSubviews(navigationBar, scrollView)
    scrollView.addSubview(scrollContentView)
    scrollContentView.addSubviews(titleLabel, proofChallengeCollectionView, bottomView)
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    scrollView.snp.makeConstraints {
      $0.top.equalTo(navigationBar.snp.bottom).offset(24)
      $0.bottom.leading.trailing.equalToSuperview()
    }
    
    scrollContentView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.width.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.top.equalToSuperview()
      $0.leading.equalToSuperview().offset(24)
    }
    
    proofChallengeCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.height.equalTo(proofChallengeCollectionView.snp.width).multipliedBy(0.83)
    }
    
    bottomView.snp.makeConstraints {
      $0.top.equalTo(proofChallengeCollectionView.snp.bottom).offset(32)
      $0.leading.trailing.bottom.equalToSuperview()
    }
  }
}

// MARK: - Bind Methods
private extension ChallengeHomeViewController {
  func bind() {
    let input = ChallengeHomeViewModel.Input(
      requestData: requestData.asSignal(),
      didTapChallenge: bottomView.didTapChallenge,
      uploadChallengeFeed: uploadChallengeFeed.asSignal(),
      didTapLoginButton: didTapLoginButton.asSignal()
    )
    let output = viewModel.transform(input: input)
    viewModelBind(for: output)
  }
  
  func viewModelBind(for output: ChallengeHomeViewModel.Output) {
    output.myChallengeFeeds
      .drive(with: self) { owner, challengeFeeds in
        owner.initalize(models: challengeFeeds)
      }
      .disposed(by: disposeBag)
    
    output.myChallenges
      .drive(bottomView.rx.dataSources)
      .disposed(by: disposeBag)
    
    output.didUploadChallengeFeed
      .emit(with: self) { owner, result in
        LoadingAnimation.logo.stop()
        if case let .success(challengeId, image) = result {
          owner.update(challengeId: challengeId, image: image.image)
        }
      }
      .disposed(by: disposeBag)
    
    output.networkUnstable
      .emit(with: self) { owner, reason in
        owner.presentNetworkUnstableAlert(reason: reason)
      }
      .disposed(by: disposeBag)
    
    output.loginTrigger
      .emit(with: self) { owner, _ in
        let alert = owner.presentLoginTriggerAlert()
        owner.bind(alert: alert)
      }
      .disposed(by: disposeBag)
    
    output.fileTooLarge
      .emit(with: self) { owner, _ in
        owner.presentFileTooLargeAlert()
      }
      .disposed(by: disposeBag)
  }
  
  func bind(for cell: ProofChallengeCell, isNotProof: Bool) {
    cell.rx.didTapImage
      .filter { _ in isNotProof }
      .bind(with: self) { owner, _ in
        owner.uploadChallengeId = cell.challengeId
        owner.requestOpenCamera(delegate: owner)
      }
      .disposed(by: disposeBag)
  }
  
  func bind(alert: AlertViewController) {
    alert.rx.didTapConfirmButton
      .bind(with: self) { owner, _ in
        owner.didTapLoginButton.accept(())
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ChallengeHomePresentable
extension ChallengeHomeViewController: ChallengeHomePresentable { }

// MARK: - UICollectionViewDataSource
extension ChallengeHomeViewController {
  func diffableDataSource() -> MyChallengeFeedDataSourceType {
    return .init(collectionView: proofChallengeCollectionView) { [weak self] collectionView, indexPath, model in
      guard let self else { return .init() }
      
      let cell = collectionView.dequeueCell(ProofChallengeCell.self, for: indexPath)
      let isLast = isLastItem(row: indexPath.row)
      cell.configure(with: model, isLast: isLast)
      bind(for: cell, isNotProof: model.type == .didNotProof)
      
      return cell
    }
  }
  
  func initalize(models: [MyChallengeFeedPresentationModel]) {
    guard let datasource else { return }
    var snapshot = datasource.snapshot()
    if snapshot.numberOfSections != 0 { snapshot.deleteSections([0]) }
    
    snapshot.appendSections([0])
    snapshot.appendItems(models)
    
    datasource.apply(snapshot)
  }
  
  func update(challengeId: Int, image: UIImage) {
    guard let datasource else { return }
    var snapshot = datasource.snapshot()
    
    guard let index = snapshot.itemIdentifiers.firstIndex(where: { $0.id == challengeId }) else { return }

    let existingModel = snapshot.itemIdentifiers[index]
    var updatedModel = existingModel
    updatedModel.type = .proofImage(image)
    
    snapshot.deleteItems([existingModel])
    snapshot.appendItems([updatedModel])
    datasource.apply(snapshot, animatingDifferences: false)
  }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ChallengeHomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      picker.dismiss(animated: true)
      return
    }
    picker.dismiss(animated: true)
    
    let popOver = UploadPhotoPopOverViewController(type: .two, image: image)
    popOver.present(to: self, animated: true)
    popOver.delegate = self
  }
}

// MARK: - Upload
extension ChallengeHomeViewController: UploadPhotoPopOverDelegate {
  func upload(_ popOver: UploadPhotoPopOverViewController, image: UIImage) {
    LoadingAnimation.logo.start()
    uploadChallengeFeed.accept((uploadChallengeId, .init(image: image)))
  }
}

// MARK: - Private Methods
private extension ChallengeHomeViewController {
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
  
  func isLastItem(row: Int) -> Bool {
    guard let datasource else { return false }
    
    let snapshot = datasource.snapshot()
    return snapshot.numberOfItems - 1 == row
  }
  
  func presentFileTooLargeAlert() {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "용량이 너무 커요",
      subTitle: "파일 용량이 너무 커, 챌린지 인증에 실패했어요. \n용량은 8MB이하만 가능해요."
    )
    alert.present(to: self, animted: true)
  }
}
