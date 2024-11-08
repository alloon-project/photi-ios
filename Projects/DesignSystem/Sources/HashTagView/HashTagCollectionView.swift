//
//  HashTagCollectionView.swift
//  DesignSystem
//
//  Created by jung on 11/8/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import SnapKit

public final class HashTagCollectionView: UICollectionView {
  public enum Allignment {
    case leading
    case center
  }
  
  // MARK: - Properties
  public var spacing: CGFloat = 8 {
    didSet { layout.minimumLineSpacing = spacing }
  }
  public let allignMent: Allignment
  
  // MARK: - UI Components
  private let layout: UICollectionViewFlowLayout
  
  // MARK: - Initializers
  public init(allignMent: Allignment) {
    self.allignMent = allignMent
    self.layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.minimumLineSpacing = spacing
    layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    super.init(frame: .zero, collectionViewLayout: layout)
    setupUI()
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - LayoutSubviews
  override public func layoutSubviews() {
    super.layoutSubviews()
    
    if case .center = allignMent {
      centerContentHorizontalyByInsetIfNeeded()
    }
  }
}

// MARK: - UI Methods
private extension HashTagCollectionView {
  func setupUI() {
    backgroundColor = .clear
    showsHorizontalScrollIndicator = false
    automaticallyAdjustsScrollIndicatorInsets = false
    contentInsetAdjustmentBehavior = .never
  }
}

// MARK: - Public Methods
public extension HashTagCollectionView {
  func centerContentHorizontalyByInsetIfNeeded() {
    if contentSize.width > frame.size.width {
      contentInset = .zero
    } else {
      contentInset = UIEdgeInsets(
        top: 0,
        left: (frame.size.width) / 2 - (contentSize.width) / 2,
        bottom: 0,
        right: 0
      )
    }
  }
}
