//
//  Provider.swift
//  AlloonNetwork
//
//  Created by jung on 4/25/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation
import RxSwift

public enum StubBehavior {
  /// stub가 아닌 실제 서버와 통신합니다.
  case never
  
  /// stub 데이터를 즉시 리턴합니다.
  case immediate
  
  /// stub 데이터를 `seconds` 이후에 리턴합니다.
  case delayed(seconds: TimeInterval)
}

public struct Provider<Target: TargetType> {
  private let stubBehavior: StubBehavior
  private let session: Session
  
  public init(
    stubBehavior: StubBehavior = .never,
    session: Session = Session()
  ) {
    self.stubBehavior = stubBehavior
    self.session = session
  }
  
  public func request<T: Decodable>(
    _ target: Target,
    type: T.Type = SuccessResponseDTO.self
  ) -> Single<BaseResponse<T>> {
    switch stubBehavior {
      case .never:
        let endPoint = endPointMapping(for: target)
        return requestNormal(endPoint, type: type)
        
      case .immediate:
        return requestStub(target, type: type)
        
      case .delayed(let seconds):
        return requestStub(target, type: type, withDelay: seconds)
    }
  }
}

// MARK: - Private Extension
private extension Provider {
  func requestNormal<T: Decodable>(_ endPoint: EndPoint, type: T.Type) -> Single<BaseResponse<T>> {
    return Single.create { single in
      Task {
        do {
          let urlRequest = try endPoint.urlRequest()
          let (data, httpResponse) = try await session.request(request: urlRequest)

          let response = try resultMapping(
            data: data,
            statusCode: httpResponse.statusCode,
            httpResponse: httpResponse,
            type: T.self
          )
          single(.success(response))
        } catch {
          single(.failure(error))
        }
      }
      return Disposables.create()
    }
  }
  
  func requestStub<T: Decodable>(
    _ target: Target,
    type: T.Type,
    withDelay: TimeInterval = 0
  ) -> Single<BaseResponse<T>> {
    return Single.create { single in
      do {
        switch target.sampleResponse {
          case let .networkResponse(statusCode, data, code, message):
            let response = try resultMapping(data: data, statusCode: statusCode, type: T.self)
            single(.success(response))
            
          case let .networkError(error):
            single(.failure(error))
        }
      } catch {
        single(.failure(error))
      }
      return Disposables.create()
    }
    .delay(.seconds(Int(withDelay)), scheduler: MainScheduler.instance)
  }
  
  func endPointMapping(for target: Target) -> EndPoint {
    let url = target.path.isEmpty ? target.baseURL : target.baseURL.appendingPathComponent(target.path)
    
    return .init(
      url: url,
      method: target.method,
      task: target.task,
      httpHeaderFields: target.headers
    )
  }
  
  func resultMapping<T: Decodable>(
    data: Data,
    statusCode: Int,
    httpResponse: HTTPURLResponse? = nil,
    type: T.Type
  ) throws -> BaseResponse<T> {
    let decoder = JSONDecoder()
    
    // 성공의 경우
    if (200..<300).contains(statusCode) {
      let decodedData = try decoder.decode(BaseResponseDTO<T>.self, from: data)
      return BaseResponse(dto: decodedData, statusCode: statusCode, response: httpResponse)
    } else {
      let decodedData = try decoder.decode(VoidResponseDTO.self, from: data)
      return BaseResponse<T>(dto: decodedData, statusCode: statusCode, response: httpResponse)
    }
  }
}
