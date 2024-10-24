//
//  HomeViewController.swift
//  HomeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import AVFoundation
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
  private var myChallengeDataSources: [MyChallengePresentationModel] = []
  
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
    
    bottomView.dataSources = myChallengeDataSources
    proofChallengeCollectionView.collectionViewLayout = compositionalLayout()
    proofChallengeCollectionView.dataSource = self
    setupUI()
  }
}

// MARK: - UI Methods
private extension HomeViewController {
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
private extension HomeViewController {
  func bind(for cell: ProofChallengeCell) {
    guard let model = cell.model else { return }
    
    cell.rx.didTapImage
      .bind(with: self) { owner, _ in
        switch model.type {
          case .didNotProof: owner.requestOpenCamera()
          case .proof: return
        }
      }
      .disposed(by: disposeBag)
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
    bind(for: cell)
    
    return cell
  }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
extension HomeViewController: UploadPhotoPopOverDelegate {
  func upload(_ popOver: UploadPhotoPopOverViewController, image: UIImage) {
    // TODO: 서버로 전송
    print(image.size)
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
  
  func requestOpenCamera() {
    AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
      guard let self else { return }
      guard isAuthorized else {
        self.displayAlertToSetting()
        return
      }
      
      openCamera()
    }
  }
  
  func displayAlertToSetting() {
    let alertController = UIAlertController(
      title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
      message: "설정 > Photi탭에서 접근을 활성화 할 수 있습니다.",
      preferredStyle: .alert
    )
    let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
      alertController.dismiss(animated: true, completion: nil)
    }
    
    let goToSetting = UIAlertAction(title: "설정으로 이동하기", style: .default) { _ in
      guard
        let settingURL = URL(string: UIApplication.openSettingsURLString),
        UIApplication.shared.canOpenURL(settingURL)
      else { return }
      UIApplication.shared.open(settingURL, options: [:])
    }
    
    [cancel, goToSetting].forEach(alertController.addAction(_:))
    DispatchQueue.main.async {
      self.present(alertController, animated: true)
    }
  }
  
  func openCamera() {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let pickerController = UIImagePickerController()
      pickerController.sourceType = .camera
      pickerController.allowsEditing = false
      pickerController.mediaTypes = ["public.image"]
      pickerController.delegate = self
      
      self.present(pickerController, animated: true)
    }
  }
}
