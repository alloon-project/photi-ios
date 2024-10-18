//
//  ProfileEditDataMapper.swift
//  Data
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import DTO
import Entity

public protocol ProfileEditDataMapper {
  func mapToProfileEditInfo(responseDTO: ProfileEditResponseDTO) -> UserProfile
}

public struct ProfileEditDataMapperImpl: ProfileEditDataMapper {
  public init() {}
  
  public func mapToProfileEditInfo(responseDTO: ProfileEditResponseDTO) -> UserProfile {
    return UserProfile(
      imageUrl: responseDTO.imageUrl,
      userName: responseDTO.userName,
      userEmail: responseDTO.userEmail
    )
  }
}
