//
//  AuthorPresentationModel.swift
//  ChallengeImpl
//
//  Created by jung on 2/26/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation

struct AuthorPresentationModel {
  let name: String
  let imageURL: URL?
}

extension AuthorPresentationModel {
  static let `default` = AuthorPresentationModel(name: "", imageURL: nil)
}
