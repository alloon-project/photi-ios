//
//  SignUpRepositoryImpl.swift
//  DTO
//
//  Created by jung on 8/14/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxSwift
import DataMapper
import Entity
import Repository
import PhotiNetwork

public struct SignUpRepositoryImpl: SignUpRepository {
private let dataMapper: SignUpDataMapper
  
  public init(dataMapper: SignUpDataMapper) {
    self.dataMapper = dataMapper
  }
  
  public func requestVerificationCode(email: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToRequestVerificationRequestDTO(email: email)
    
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .never)
            .request(SignUpAPI.requestVerificationCode(dto: requestDTO)).value

          if result.statusCode == 201 {
            single(.success(()))
          } else if result.statusCode == 409 {
            single(.failure(APIError.signUpFailed(reason: .emailAlreadyExists)))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(APIError.serverError))
        }
      }
      
      return Disposables.create()
    }
  }
  
  public func verifyCode(email: String, code: String) -> Single<Void> {
    let requestDTO = dataMapper.mapToVerifyCodeRequestDTO(email: email, code: code)
    
    return Single.create { single in
      Task {
        do {
          let result = try await Provider(stubBehavior: .immediate)
            .request(SignUpAPI.verifyCode(dto: requestDTO)).value

          if result.statusCode == 200 {
            single(.success(()))
          } else if result.statusCode == 400 {
            single(.failure(APIError.signUpFailed(reason: .invalidVerificationCode)))
          } else if result.statusCode == 404 {
            single(.failure(APIError.signUpFailed(reason: .emailNotFound)))
          } else {
            single(.failure(APIError.serverError))
          }
        } catch {
          single(.failure(APIError.serverError))
        }
      }
      
      return Disposables.create()
    }
  }
}
