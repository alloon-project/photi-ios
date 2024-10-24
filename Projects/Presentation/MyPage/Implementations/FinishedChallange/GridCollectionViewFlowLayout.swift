//
//  GridCollectionViewFlowLayout.swift
//  Presentation
//
//  Created by wooseob on 10/24/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit

final class GridCollectionViewFlowLayout: UICollectionViewFlowLayout {
  var ratioHeightToWidth = 1.0
  var numberOfColumns = 1
  var cellSpacing = 0.0 {
    didSet {
      self.minimumLineSpacing = self.cellSpacing
      self.minimumInteritemSpacing = self.cellSpacing
    }
  }
  
  override init() {
    super.init()
    self.scrollDirection = .vertical
  }
  required init?(coder: NSCoder) {
    fatalError()
  }
}
