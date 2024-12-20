//
//  SelfSizingTableView.swift
//  Core
//
//  Created by jung on 5/11/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

open class SelfSizingTableView: UITableView {
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
  public init(minHeight: CGFloat = 0, maxHeight: CGFloat?) {
    self.minHeight = minHeight
    self.maxHeight = maxHeight
    super.init(frame: .zero, style: .plain)
  }
  
  public convenience init() {
    self.init(minHeight: 0, maxHeight: nil)
  }
  
  @available(*, unavailable)
  required public init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
