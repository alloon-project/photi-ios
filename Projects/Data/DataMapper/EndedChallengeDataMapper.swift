//
//  EndedChallengeDataMapper.swift
//  Data
//
//  Created by 임우섭 on 11/3/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO
import Entity

public protocol EndedChallengeDataMapper {
  func mapToEndedChallengeRequestDTO(page: Int, size: Int) -> EndedChallengeRequestDTO
  func mapToEndedChallenge(responseDTO: EndedChallengeResponseDTO) -> [EndedChallenge]
}

public struct EndedChallengeDataMapperImpl: EndedChallengeDataMapper {
  public init() {}

  public func mapToEndedChallengeRequestDTO(page: Int, size: Int) -> EndedChallengeRequestDTO {
    return EndedChallengeRequestDTO(page: page, size: size)
  }
  
  public func mapToEndedChallenge(responseDTO: EndedChallengeResponseDTO) -> [EndedChallenge] {
    let contents = responseDTO.content.map { EndedChallenge(
      id: $0.id,
      name: $0.name,
      imageUrl: $0.imageUrl,
      endDate: $0.endDate,
      currentMemberCnt: $0.currentMemberCnt,
      memberImages: $0.memberImages
    ) }
    return contents
  }
}
