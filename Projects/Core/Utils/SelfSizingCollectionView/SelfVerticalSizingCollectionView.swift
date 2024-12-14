//
//  SelfSizingCollectionView.swift
//  Core
//
//  Created by jung on 12/11/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

open class SelfVerticalSizingCollectionView: UICollectionView {
  private let minHeight: CGFloat
  private let maxHeight: CGFloat?
  
  open override var contentSize: CGSize {
    didSet {
      self.invalidateIntrinsicContentSize()
    }
  }
  
  override public var intrinsicContentSize: CGSize {
    layoutIfNeeded()
    
    var height: CGFloat = 0
      
    if let maxHeight = maxHeight, contentSize.height > maxHeight {
      height = maxHeight
    } else if contentSize.height < minHeight {
      height = minHeight
    } else {
      height = contentSize.height
    }
    
    return CGSize(width: UIView.noIntrinsicMetric, height: height)
  }
  
  // MARK: - Initalizers
  public init(
    minHeight: CGFloat = 0,
    maxHeight: CGFloat?,
    layout: UICollectionViewLayout
  ) {
    self.minHeight = minHeight
    self.maxHeight = maxHeight
    super.init(frame: .zero, collectionViewLayout: layout)
  }
  
  public convenience init(layout: UICollectionViewLayout) {
    self.init(minHeight: 0, maxHeight: nil, layout: layout)
  }
  
  @available(*, unavailable)
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
