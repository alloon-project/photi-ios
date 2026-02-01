//
//  ChallengeModifyDraft.swift
//  ChallengeImpl
//
//  Created by jung on 12/29/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import CoreUI

/// "편집 중 상태"를 나타내는 모델
struct ChallengeModifyDraft {
  var name: String
  var hashtags: [String]
  var goal: String
  var verificationTime: String
  var deadline: String
  var rules: [String]

  // 이미지
  var existingImageURL: String
  var newImage: UIImageWrapper?   // nil이면 변경 없음
}
