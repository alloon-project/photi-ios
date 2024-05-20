//
//  DropDownTableView.swift
//  DesignSystem
//
//  Created by jung on 5/17/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import Core

final class DropDownTableView: UITableView {
  // MARK: - Properties
  private let itemHeight: CGFloat = 48
  private let minHeight: CGFloat = 0
  private let maxHeight: CGFloat = 192 // 48 * 4
  
  override public var intrinsicContentSize: CGSize {
    layoutIfNeeded()
    if contentSize.height > maxHeight {
      return CGSize(width: contentSize.width, height: maxHeight)
    } else if contentSize.height < minHeight {
      return CGSize(width: contentSize.width, height: minHeight)
    } else {
      return contentSize
    }
  }
  
  // MARK: - Initializers
  override init(frame: CGRect, style: UITableView.Style) {
    super.init(frame: frame, style: style)
    
    rowHeight = itemHeight
    layer.cornerRadius = 16
    separatorStyle = .none
    
    self.registerCell(DropDownCell.self)
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - override Layout Methods
  override public func layoutSubviews() {
    super.layoutSubviews()
    if bounds.size != intrinsicContentSize {
      invalidateIntrinsicContentSize()
    }
  }
}
