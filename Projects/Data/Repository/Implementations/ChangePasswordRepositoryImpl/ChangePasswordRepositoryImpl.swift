//
//  ChangePasswordRepositoryImpl.swift
//  Data
//
//  Created by wooseob on 12/5/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity
import Repository
import PhotiNetwork

public struct ChangePasswordRepositoryImpl: ChangePasswordRepository {
  private let dataMapper: ChangePasswordDataMapper
  
  public init(dataMapper: ChangePasswordDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func changePassword(
    password: String,
    newPassword: String,
    newPasswordReEnter: String
  ) -> Single<Void> {
    let requestDTO = dataMapper.mapToChangePasswordRequestDTO(
      password: password,
      newPassword: newPassword,
      newPasswordReEnter: newPasswordReEnter
    )
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(ChangePasswordAPI.changePassword(dto: requestDTO)).value
          
          if result.statusCode == 200 {
            single(.success(()))
          } else if result.statusCode == 400 {
            single(.failure(APIError.myPageFailed(reason: .passwordMatchInvalid)))
          } else if result.statusCode == 401 || result.statusCode == 403 {
            single(.failure(APIError.authenticationFailed))
          }
        } catch {
          single(.failure(error))
        }
      }
      
      return Disposables.create()
    }
  }
}
