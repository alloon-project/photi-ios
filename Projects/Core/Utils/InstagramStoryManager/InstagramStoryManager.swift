//
//  InstagramStoryManager.swift
//  Core
//
//  Created by jung on 8/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit

public struct InstagramStoryManager {
  public enum InstagramStoryError: Error {
    case notInstalled
    case failedConvertToData
  }
  
  public static let shared = InstagramStoryManager()
  private var urlString: String {
    guard let appID = Bundle.main.object(forInfoDictionaryKey: "MetaAppID") as? String else {
      fatalError("Instagram APP ID could not find in plist. Please check plist or user-defined!")
    }
    
    return "instagram-stories://share?source_application=\(appID)"
  }
  
  private init() { }

  public func prepareInstagramStoryShare(view: UIView, size: CGSize? = nil) throws -> URL {
    if let size { view.frame.size = size }
    guard let imageData = createStory(from: view) else { throw InstagramStoryError.failedConvertToData }
    
    guard
      let urlScheme = URL(string: urlString),
      UIApplication.shared.canOpenURL(urlScheme) else { throw InstagramStoryError.notInstalled }
    let pasteboardItems: [String: Any] = [
      "com.instagram.sharedSticker.backgroundImage": imageData
    ]
    
    let pasteboardOptions = [
      UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)
    ]
    
    UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
    
    return urlScheme
  }
  
  private func createStory(from view: UIView) -> Data? {
    view.layoutIfNeeded()
    let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
    let image = renderer.image { context in
      view.layer.render(in: context.cgContext)
    }
    return image.pngData()
  }
}
