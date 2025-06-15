//
//  ChallengeCoverViewController.swift
//  Presentation
//
//  Created by 임우섭 on 3/30/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Kingfisher
import RxCocoa
import RxSwift
import SnapKit
import Core
import DesignSystem

final class ChallengeCoverViewController: UIViewController, ViewControllerable, PhotoRequestable {
  // MARK: - Properties
  private let mode: ChallengeOrganizeMode
  private var cellDataSources = [SampleImageCellPresentaionModel(imageUrlString: "Photo")] {
    didSet {
      imageCollectionView.reloadData()
    }
  }
  private let didTapSmapleImageCell = PublishRelay<Int>()

  private let disposeBag = DisposeBag()
  private let viewModel: ChallengeCoverViewModel
  
  private let viewDidLoadRelay = PublishRelay<Void>()
  private var coverImageRelay: BehaviorRelay<UIImageWrapper> = BehaviorRelay(
    value: .init(image: .challengeOrganizeLuckyday)
  )
  
  // MARK: - UI Components
  private let navigationBar = PhotiNavigationBar(leftView: .backButton, displayMode: .dark)
  
  private let progressBar = LargeProgressBar(step: .three)
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.attributedText = "대표 이미지를 정해주세요!".attributedString(
      font: .heading4,
      color: .gray900
    )
    
    return label
  }()
  
  private let mainImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = .challengeOrganizeLuckyday
    imageView.layer.cornerRadius = 16
    imageView.layer.masksToBounds = true
    return imageView
  }()
  
  private let imageCollectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    layout.minimumLineSpacing = 8
    layout.minimumInteritemSpacing = 8
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 72, height: 92)
    layout.sectionInset = .init(top: 0, left: 24, bottom: 0, right: 0)
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    return collectionView
  }()
  
  private let nextButton = FilledRoundButton(
    type: .primary,
    size: .xLarge,
    text: "다음"
  )
  
  // MARK: - Initialziers
  init(
    mode: ChallengeOrganizeMode,
    viewModel: ChallengeCoverViewModel
  ) {
    self.mode = mode
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cylces
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    bind()
    
    imageCollectionView.delegate = self
    imageCollectionView.dataSource = self
    imageCollectionView.registerCell(SampleImageCell.self)
    viewDidLoadRelay.accept(())
  }
  
  // MARK: - UI Responder
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesEnded(touches, with: event)
    
    view.endEditing(true)
  }
}

// MARK: - UI Methods
private extension ChallengeCoverViewController {
  func setupUI() {
    view.backgroundColor = .white
    setViewHierarchy()
    setConstraints()
    
    if case .modify = mode {
      navigationBar.title = "대표 이미지 수정"
      nextButton.title = "저장하기"
    }
  }
  
  func setViewHierarchy() {
    view.addSubviews(
      navigationBar,
      progressBar,
      titleLabel,
      mainImageView,
      imageCollectionView,
      nextButton
    )
  }
  
  func setConstraints() {
    navigationBar.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(view.safeAreaLayoutGuide)
      $0.height.equalTo(56)
    }
    
    if case .modify = mode {
      titleLabel.snp.makeConstraints {
        $0.top.equalTo(navigationBar.snp.bottom).offset(36)
        $0.leading.equalToSuperview().offset(24)
      }
    } else {
      progressBar.snp.makeConstraints {
        $0.top.equalTo(navigationBar.snp.bottom).offset(8)
        $0.leading.trailing.equalToSuperview().inset(24)
      }
      
      titleLabel.snp.makeConstraints {
        $0.top.equalTo(progressBar.snp.bottom).offset(48)
        $0.leading.equalToSuperview().offset(24)
      }
    }
    
    mainImageView.snp.makeConstraints {
      $0.leading.equalToSuperview().offset(24)
      $0.trailing.equalToSuperview().inset(24)
      $0.top.equalTo(titleLabel.snp.bottom).offset(24)
      $0.height.equalTo(UIScreen.main.bounds.width - 48)
    }
    
    imageCollectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview()
      $0.top.equalTo(mainImageView.snp.bottom).offset(28)
      $0.height.equalTo(96)
    }
    
    nextButton.snp.makeConstraints {
      $0.centerX.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
  }
}

// MARK: - Bind Methods
private extension ChallengeCoverViewController {
  func bind() {
    let input = ChallengeCoverViewModel.Input(
      viewDidLoad: viewDidLoadRelay.asSignal(),
      didTapBackButton: navigationBar.rx.didTapBackButton,
      challengeCoverImage: coverImageRelay.asObservable(),
      didTapNextButton: nextButton.rx.tap
    )
    
    let output = viewModel.transform(input: input)
    bind(for: output)
  }
  
  func bind(for output: ChallengeCoverViewModel.Output) {
    output.sampleImages
      .emit(with: self) { owner, imageList in
        var newDataSources = [SampleImageCellPresentaionModel(imageUrlString: "Photo")]
        newDataSources.append(contentsOf: imageList.map { SampleImageCellPresentaionModel(imageUrlString: $0) })
        owner.cellDataSources = newDataSources
      }.disposed(by: disposeBag)
    
    output.imageSizeError
      .emit(with: self) { owner, _ in
        owner.presentFileTooLargeAlert()
      }.disposed(by: disposeBag)
  }
}

// MARK: - ChallengeCoverPresentable
extension ChallengeCoverViewController: ChallengeCoverPresentable { }

// MARK: - Private Methods
private extension ChallengeCoverViewController {
  func presentFileTooLargeAlert() {
    let alert = AlertViewController(
      alertType: .confirm,
      title: "용량이 너무 커요"
    )
    alert.present(to: self, animted: true)
  }
}
// MARK: - UICollectionView Delegate
extension ChallengeCoverViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    didTapSmapleImageCell.accept(indexPath.item)
    
    if indexPath.item == 0 { // 기본일경우
      requestOpenLibrary(delegate: self)
    } else { // 서버에서 받아온 이미지
      guard let url = URL(string: cellDataSources[indexPath.item].imageUrlString) else { return }
      mainImageView.kf.setImage(with: url)
      guard let coverImage = mainImageView.image else { return }
      coverImageRelay.accept(UIImageWrapper(image: coverImage))
    }
  }
}

// MARK: - UICollectionview DataSources
extension ChallengeCoverViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    cellDataSources.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(SampleImageCell.self, for: indexPath)
    cell.configure(with: cellDataSources[indexPath.item])
    return cell
  }
}

extension ChallengeCoverViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(
    _ picker: UIImagePickerController,
    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
  ) {
    guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
      picker.dismiss(animated: true)
      return
    }
    picker.dismiss(animated: true)
    
    self.mainImageView.image = image
    coverImageRelay.accept(UIImageWrapper(image: image))
  }
}
