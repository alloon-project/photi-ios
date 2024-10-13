//
//  UploadPhotoPopOverViewController.swift
//  DesignSystem
//
//  Created by jung on 10/10/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

public protocol UploadPhotoPopOverDelegate: AnyObject {
  func upload(_ popOver: UploadPhotoPopOverViewController, image: UIImage)
}

public final class UploadPhotoPopOverViewController: PopOverViewController {
  public enum ButtonType {
    case one, two
  }
  
  // MARK: - Properties
  public weak var delegate: UploadPhotoPopOverDelegate?

  private let type: ButtonType
  public var image: UIImage {
    didSet { imageView.image = image }
  }
  
  // MARK: - UI Components
  private let imageView = UIImageView()
  private let buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    stackView.spacing = 15
    
    return stackView
  }()
  
  private let uploadButton: IconRoundButton
  private lazy var cancelButton = FilledRoundButton(type: .quaternary, size: .small, text: "취소하기")
  
  // MARK: - Initializers
  public init(type: ButtonType, image: UIImage) {
    self.type = type
    self.image = image
    var buttonSize: ButtonSize = .small
    if case .one = type { buttonSize = .medium }
    self.uploadButton = IconRoundButton(text: "올리기", icon: .rocketWhite, type: .primary, size: buttonSize)
    
    super.init(nibName: nil, bundle: nil)
    imageView.image = image
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Life Cycles
  public override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    addTargets()
  }
}

// MARK: - UI Methods
private extension UploadPhotoPopOverViewController {
  func setupUI() {
    if case .two = type {
      buttonStackView.addArrangedSubview(cancelButton)
    }
    setViewHierarchy()
    setConstraints()
  }
  
  func setViewHierarchy() {
    self.containerView.addSubviews(imageView, buttonStackView)
    buttonStackView.addArrangedSubview(uploadButton)
  }
  
  func setConstraints() {
    imageView.snp.makeConstraints {
      $0.edges.equalToSuperview()
      $0.height.equalTo(588)
      $0.width.equalTo(327)
    }
    
    buttonStackView.snp.makeConstraints {
      $0.bottom.equalToSuperview().offset(-24)
      $0.centerX.equalToSuperview()
    }
  }
}

// MARK: - Private Methods
private extension UploadPhotoPopOverViewController {
  func addTargets() {
    uploadButton.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        self.delegate?.upload(self, image: self.image)
      },
      for: .touchUpInside
    )
    
    guard case .two = type else { return }
    cancelButton.addAction(
      UIAction { [weak self] _ in
        guard let self else { return }
        self.dismissPopOver()
      },
      for: .touchUpInside
    )
  }
}
