//
//  CameraRequestable.swift
//  Core
//
//  Created by jung on 12/12/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import AVFoundation
import UIKit

public protocol CameraRequestable: AnyObject {
  func requestOpenCamera(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate))
}

public extension CameraRequestable where Self: UIViewController {
  func requestOpenCamera(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
    AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
      guard let self else { return }
      guard isAuthorized else {
        self.displayAlertToSetting()
        return
      }
      
      openCamera(delegate: delegate)
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
  
  func openCamera(delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)) {
    DispatchQueue.main.async { [weak self] in
      guard let self else { return }
      let pickerController = UIImagePickerController()
      pickerController.sourceType = .camera
      pickerController.allowsEditing = false
      pickerController.mediaTypes = ["public.image"]
      pickerController.delegate = delegate
      
      self.present(pickerController, animated: true)
    }
  }
}
