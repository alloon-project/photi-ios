//
//  SelectBottomSheet.swift
//  DesignSystem
//
//  Created by jung on 7/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Combine
import SnapKit
import Core

public protocol SelectBottomSheetDelegate: AnyObject {
  func didSelect(at index: Int)
}

public final class SelectBottomSheetViewController: BottomSheetViewController {
  private var cancellables = Set<AnyCancellable>()
  
  private weak var delegate: SelectBottomSheetDelegate?
  
  public var dataSource: [SelectDataSource] {
    didSet { collectionView.reloadData() }
  }
  public var titleString: String {
    didSet { setTitleLabel(titleString) }
  }
  
  // MARK: - UI Components
  private let topView = UIView()
  private let titleLabel = UILabel()
  
  private let closeButton: UIButton = {
    let button = UIButton()
    button.setImage(.closeCircleLight, for: .normal)
    button.layer.cornerRadius = 12
    
    return button
  }()  
  
  private let collectionView: UICollectionView = {
    let layout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    layout.minimumInteritemSpacing = 11
    collectionView.registerCell(SelectCell.self)
    
    return collectionView
  }()
  
  // MARK: - Initializers
  public init(dataSource: [SelectDataSource], title: String) {
    self.dataSource = dataSource
    self.titleString = title
    super.init(nibName: nil, bundle: nil)
  }
  
  public convenience init() {
    self.init(dataSource: [], title: "")
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  public override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.dataSource = self
    collectionView.delegate = self
    setupUI()
    bind()
  }
}

// MARK: - UI Methods
private extension SelectBottomSheetViewController {
  func setupUI() {
    setViewHierarchy()
    setConstraints()
    setTitleLabel(titleString)
  }
  
  func setViewHierarchy() {
    self.contentView.addSubviews(topView, collectionView)
    topView.addSubviews(titleLabel, closeButton)
  }
  
  func setConstraints() {
    contentView.snp.makeConstraints {
      $0.top.equalToSuperview().offset(28)
      $0.leading.trailing.equalToSuperview()
      $0.bottom.equalToSuperview().offset(-56)
    }
    
    topView.snp.makeConstraints {
      $0.height.equalTo(32)
      $0.top.leading.trailing.equalToSuperview()
    }
    
    titleLabel.snp.makeConstraints {
      $0.center.equalToSuperview()
    }
    
    closeButton.snp.makeConstraints {
      $0.centerY.equalToSuperview()
      $0.trailing.equalToSuperview().offset(-24)
    }
    
    collectionView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(24)
      $0.bottom.equalToSuperview()
      $0.top.equalTo(topView.snp.bottom).offset(32)
      $0.height.equalTo(144)
    }
  }
}

// MARK: - Bind
private extension SelectBottomSheetViewController {
  func bind() {
    closeButton.tap()
      .sinkOnMain(with: self) { owner, _ in
        owner.dismissBottomSheet()
      }.store(in: &cancellables)
  }
}

// MARK: - UICollectionViewDelegate
extension SelectBottomSheetViewController: UICollectionViewDelegate { 
  public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    delegate?.didSelect(at: indexPath.row)
    dismissBottomSheet()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension SelectBottomSheetViewController: UICollectionViewDelegateFlowLayout {
  public func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    return CGSize(width: 158, height: 144)
  }
}

// MARK: - UICollectionViewDataSource
extension SelectBottomSheetViewController: UICollectionViewDataSource {
  public func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return dataSource.count
  }
  
  public func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(SelectCell.self, for: indexPath)
    
    cell.configure(with: dataSource[indexPath.item])
    return cell
  }
}

// MARK: - Private Methods
private extension SelectBottomSheetViewController {
  func setTitleLabel(_ title: String) {
    self.titleLabel.attributedText = title.attributedString(font: .body1Bold, color: .gray900)
  }
}
