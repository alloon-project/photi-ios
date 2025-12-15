//
//  ShareableImageProvider.swift
//  Core
//
//  Created by wooseob on 9/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import LinkPresentation

public final class ShareableChallengeProvider: NSObject, UIActivityItemSource {
  private let image: UIImage
  private let challengeName: String
  private let challengeId: Int
  private let invitationCode: String?
  
  public init(
    image: UIImage,
    challengeName: String,
    challengeId: Int,
    invitationCode: String?
  ) {
    self.image = image
    self.challengeName = challengeName
    self.challengeId = challengeId
    self.invitationCode = invitationCode
    super.init()
  }
  
  public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
    return ""
  }
  
  public func activityViewController(
    _ activityViewController: UIActivityViewController,
    itemForActivityType activityType: UIActivity.ActivityType?
  ) -> Any? {
      var message = "\"\(challengeName)\" 챌린지에 함께 참여해보세요!"
      if let invitationCode = invitationCode {
          message += "\n *초대코드: \(invitationCode)"
      }
      message += "\nphoti.app://invite?challengeId=\(challengeId)"
      return message
  }
  
  public func activityViewControllerLinkMetadata(_ activityViewController: UIActivityViewController) -> LPLinkMetadata? {
    guard image.jpegData(compressionQuality: 1.0) != nil else { return nil }
    let metadata = LPLinkMetadata()
    
    var title = "\"\(challengeName)\"챌린지에 함께 참여해보세요!"
    if let invitationCode = invitationCode {
      title += "\n *초대코드: \(invitationCode)"
    }

    metadata.title = title
    metadata.originalURL = URL(string: "photi.app://invite?challengeId=\(challengeId)")
    
    metadata.imageProvider = NSItemProvider(object: image)
    return metadata
  }
}

private extension Data {
  func fileSize() -> String {
    let size = Double(self.count)
    if size < 1024 {
      return String(format: "%.2f bytes", size)
    } else if size < 1024 * 1024 {
      return String(format: "%.2f KB", size/1024.0)
    } else {
      return String(format: "%.2f MB", size/(1024.0*1024.0))
    }
  }
}
