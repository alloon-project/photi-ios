//
//  PhotoRequestable.swift
//  Core
//
//  Created by 임우섭 on 4/27/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Photos
import UIKit

public protocol PhotoRequestable: AnyObject {
  func requestOpenLibrary(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
}

public extension PhotoRequestable where Self: UIViewController {
  func requestOpenLibrary(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
      let status = PHPhotoLibrary.authorizationStatus()
      
      switch status {
      case .authorized, .limited:
        openLibrary(delegate: delegate)
        
      case .notDetermined:
        PHPhotoLibrary.requestAuthorization { [weak self] newStatus in
          guard let self else { return }
          if newStatus == .authorized || newStatus == .limited {
            self.openLibrary(delegate: delegate)
          } else {
            self.displayAlertToSetting()
          }
        }
        
      default:
        displayAlertToSetting()
      }
    }
  
  func displayAlertToSetting() {
    let alertController = UIAlertController(
      title: "현재 카메라 사용에 대한 접근 권한이 없습니다.",
      message: "설정 > Photi탭에서 접근을 활성화 할 수 있습니다.",
      preferredStyle: .alert
    )
    let cancel = UIAlertAction(title: "취소", style: .cancel) { _ in
      alertController.dismiss(animated: true, completion: nil)
    }
    
    let goToSetting = UIAlertAction(title: "설정으로 이동하기", style: .default) { _ in
      guard
        let settingURL = URL(string: UIApplication.openSettingsURLString),
        UIApplication.shared.canOpenURL(settingURL)
      else { return }
      UIApplication.shared.open(settingURL, options: [:])
    }
    
    [cancel, goToSetting].forEach(alertController.addAction(_:))
    DispatchQueue.main.async {
      self.present(alertController, animated: true)
    }
  }
  
  func openLibrary(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
     DispatchQueue.main.async { [weak self] in
       guard let self else { return }
       let pickerController = UIImagePickerController()
       pickerController.sourceType = .photoLibrary
       pickerController.allowsEditing = false
       pickerController.mediaTypes = ["public.image"]
       pickerController.delegate = delegate
       
       self.present(pickerController, animated: true)
     }
   }
}
