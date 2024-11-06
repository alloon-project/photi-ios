//
//  MyPageDataMapper.swift
//  Data
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO
import Entity

public protocol MyPageDataMapper {
  func mapToUserChallengeHistory(responseDTO: UserChallengeHistoryResponseDTO) -> UserChallengeHistory
}

public struct MyPageDataMapperImpl: MyPageDataMapper {
  public init() {}
  
  public func mapToUserChallengeHistory(responseDTO: UserChallengeHistoryResponseDTO) -> UserChallengeHistory {
    return UserChallengeHistory(
      userName: responseDTO.userName,
      imageUrl: responseDTO.imageUrl,
      feedCnt: responseDTO.feedCnt,
      endedChallengeCnt: responseDTO.endedChallengeCnt
    )
  }
}
