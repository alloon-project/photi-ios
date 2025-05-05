//
//  ChallengeSampleImageResponseDTO.swift
//  Data
//
//  Created by 임우섭 on 4/15/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ChallengeSampleImageResponseDTO: Decodable {
  public let list: [String]
}

public extension ChallengeSampleImageResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": {
    "list": [
      "https://photi-bucket-1.s3.ap-northeast-2.amazonaws.com/challenges/examples/img_cover_health.jpg",
      "https://photi-bucket-1.s3.ap-northeast-2.amazonaws.com/challenges/examples/img_cover_lucky.jpg",
      "https://photi-bucket-1.s3.ap-northeast-2.amazonaws.com/challenges/examples/img_cover_photo.jpg",
      "https://photi-bucket-1.s3.ap-northeast-2.amazonaws.com/challenges/examples/img_cover_study.jpg",
      "https://photi-bucket-1.s3.ap-northeast-2.amazonaws.com/challenges/examples/img_health.jpg",
      "https://photi-bucket-1.s3.ap-northeast-2.amazonaws.com/challenges/examples/img_running.jpg"
    ]
  }
}
"""
}
