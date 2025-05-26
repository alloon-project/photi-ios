//
//  DashLineSegmentControl.swift
//  DesignSystem
//
//  Created by jung on 5/21/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public final class DashLineSegmentControl: PhotiSegmentControl {
  override func segmentButton(title: String, tag: Int) -> SegmentButton {
    let button = DashLineSegmentButton(title: title)
    button.tag = tag
    
    return button
  }
}
