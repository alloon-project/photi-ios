//
//  CenterSegmentButton.swift
//  DesignSystem
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import SnapKit
import Core

final class CenterSegmentButton: SegmentButton {
  override var textColor: UIColor {
    return isSelected ? .blue500 : .gray400
  }
}
