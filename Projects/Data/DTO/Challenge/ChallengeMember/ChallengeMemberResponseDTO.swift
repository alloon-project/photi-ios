//
//  ChallengeMemberResponseDTO.swift
//  DTO
//
//  Created by jung on 3/13/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

public struct ChallengeMemberResponseDTO: Decodable {
  public let id: Int
  public let username: String
  public let imageUrl: String?
  public let isCreator: Bool
  public let duration: Int
  public let goal: String?
}

public extension ChallengeMemberResponseDTO {
  static let stubData = """
{
  "code": "200 OK",
  "message": "성공",
  "data": [
    {
      "id": 1,
      "username": "photi",
      "imageUrl": "https://url.kr/5MhHhD",
      "isCreator": true,
      "duration": 10,
      "goal": "열심히 운동하기!!"
    },
    {
      "id": 2,
      "username": "photi1",
      "imageUrl": "https://url.kr/5MhHhD",
      "isCreator": false,
      "duration": 1,
      "goal": "열심히 운동하기!!"
    },
    {
      "id": 3,
      "username": "photi2",
      "imageUrl": "https://url.kr/5MhHhD",
      "isCreator": false,
      "duration": 0,
      "goal": "열심히 운동하기!!"
    },
    {
      "id": 4,
      "username": "photi3",
      "imageUrl": "https://url.kr/5MhHhD",
      "isCreator": false,
      "duration": 10,
      "goal": "열심히 운동하기!!"
    },
    {
      "id": 5,
      "username": "photi4",
      "imageUrl": "https://url.kr/5MhHhD",
      "isCreator": false,
      "duration": 300,
      "goal": "열심히 운동하기!!열심히 운동하기!!열심히 운동하기!!열심히 운동하기!!열심히 운동하기!!열심히 운동하기!!열심히 운동하기!!열심히 운동하기!!"
    }
  ]
}
"""
}
