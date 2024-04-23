//
//  NetworkError.swift
//  DTO
//
//  Created by jung on 4/24/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

public enum NetworkError: Error {
  public enum ParameterEncodingFailureReason {
    case missingURL
    case jsonEncodingFailed(error: Error)
    
    var localizedDescription: String {
      switch self {
        case .missingURL:
          return "URL request to encode was missing a URL"
          
        case let .jsonEncodingFailed(error):
          return "JSON could not be encoded because of error:\n\(error.localizedDescription)"
      }
    }
  }
  
  public enum NetworkFailedReason {
    case httpNoResponse
    case jsonDecodingFailed
    
    var localizedDescription: String {
      switch self {
        case .httpNoResponse:
          return "HTTPURLResponse optional binding failed"
          
        case .jsonDecodingFailed:
          return "jsonDecodingFailed"
      }
    }
  }
  
  case parameterEncodingFailed(reason: ParameterEncodingFailureReason)
  case networkFailed(reason: NetworkFailedReason)
}
