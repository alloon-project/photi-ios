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
    static let itemWidth: CGFloat = 288
    static let groupSpacing: CGFloat = 16
  }
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeHomeViewModel
  
  private var myChallengeFeedDataSources: [MyChallengeFeedPresentationModel] = [] {
    didSet { proofChallengeCollectionView.reloadData() }
  }
  private var myChallengeDataSources: [MyChallengePresentationModel] = [] {
    didSet { bottomView.dataSources = myChallengeDataSources }
  }
  
  private let requestData = PublishRelay<Void>()
  
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
  
  private let proofChallengeCollectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
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
    
    bottomView.dataSources = myChallengeDataSources
    proofChallengeCollectionView.collectionViewLayout = compositionalLayout()
    proofChallengeCollectionView.dataSource = self
    setupUI()
    bind()
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
      $0.height.equalTo(298)
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
    let input = ChallengeHomeViewModel.Input(requestData: requestData.asSignal())
    let output = viewModel.transform(input: input)
    viewModelBind(for: output)
  }
  
  func viewModelBind(for output: ChallengeHomeViewModel.Output) {
    output.myChallengeFeeds
      .drive(self.rx.myChallengeFeedDataSources)
      .disposed(by: disposeBag)
    
    output.myChallenges
      .drive(self.rx.myChallengeDataSources)
      .disposed(by: disposeBag)
  }
  
  func bind(for cell: ProofChallengeCell) {
    guard let model = cell.model else { return }
    
    cell.rx.didTapImage
      .bind(with: self) { owner, _ in
        switch model.type {
          case .didNotProof: owner.requestOpenCamera(delegate: owner)
          case .proof: return
        }
      }
      .disposed(by: disposeBag)
  }
}

// MARK: - ChallengeHomePresentable
extension ChallengeHomeViewController: ChallengeHomePresentable { }

// MARK: - UICollectionViewDataSource
extension ChallengeHomeViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return myChallengeFeedDataSources.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(ProofChallengeCell.self, for: indexPath)
    let model = myChallengeFeedDataSources[indexPath.row]
    cell.configure(with: model, isLast: indexPath.row == myChallengeFeedDataSources.count - 1)
    bind(for: cell)
    
    return cell
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
    // TODO: 서버로 전송
    print(image.size)
  }
}

// MARK: - Private Methods
private extension ChallengeHomeViewController {
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
