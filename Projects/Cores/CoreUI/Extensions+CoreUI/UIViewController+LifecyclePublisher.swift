//
//  UIViewController+RxExtension.swift
//  Core
//
//  Created by 임우섭 on 9/22/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import UIKit
import Combine
import ObjectiveC

// MARK: - Associated Object Keys
private var viewDidLoadSubjectKey: UInt8 = 0
private var viewWillAppearSubjectKey: UInt8 = 0
private var viewDidAppearSubjectKey: UInt8 = 0
private var viewWillDisappearSubjectKey: UInt8 = 0
private var viewDidDisappearSubjectKey: UInt8 = 0
private var viewWillLayoutSubviewsSubjectKey: UInt8 = 0
private var viewDidLayoutSubviewsSubjectKey: UInt8 = 0
private var willMoveToParentSubjectKey: UInt8 = 0
private var didMoveToParentSubjectKey: UInt8 = 0
private var didReceiveMemoryWarningSubjectKey: UInt8 = 0
private var isDismissingSubjectKey: UInt8 = 0

// MARK: - Publishers
public extension UIViewController {
  var viewDidLoadPublisher: AnyPublisher<Void, Never> {
    return viewDidLoadSubject.eraseToAnyPublisher()
  }
  
  var viewWillAppearPublisher: AnyPublisher<Bool, Never> {
    return viewWillAppearSubject.eraseToAnyPublisher()
  }
  
  var viewDidAppearPublisher: AnyPublisher<Bool, Never> {
    return viewDidAppearSubject.eraseToAnyPublisher()
  }
  
  var viewWillDisappearPublisher: AnyPublisher<Bool, Never> {
    return viewWillDisappearSubject.eraseToAnyPublisher()
  }
  
  var viewDidDisappearPublisher: AnyPublisher<Bool, Never> {
    return viewDidDisappearSubject.eraseToAnyPublisher()
  }
  
  var viewWillLayoutSubviewsPublisher: AnyPublisher<Void, Never> {
    return viewWillLayoutSubviewsSubject.eraseToAnyPublisher()
  }
  
  var viewDidLayoutSubviewsPublisher: AnyPublisher<Void, Never> {
    return viewDidLayoutSubviewsSubject.eraseToAnyPublisher()
  }
  
  var willMoveToParentViewControllerPublisher: AnyPublisher<UIViewController?, Never> {
    return willMoveToParentSubject.eraseToAnyPublisher()
  }
  
  var didMoveToParentViewControllerPublisher: AnyPublisher<UIViewController?, Never> {
    return didMoveToParentSubject.eraseToAnyPublisher()
  }
  
  var didReceiveMemoryWarningPublisher: AnyPublisher<Void, Never> {
    return didReceiveMemoryWarningSubject.eraseToAnyPublisher()
  }
  
  var isVisiblePublisher: AnyPublisher<Bool, Never> {
    let viewDidAppear = viewDidAppearPublisher.map { _ in true }
    let viewWillDisappear = viewWillDisappearPublisher.map { _ in false }
    return Publishers.Merge(viewDidAppear, viewWillDisappear).eraseToAnyPublisher()
  }
  
  var isDismissingPublisher: AnyPublisher<Bool, Never> {
    return isDismissingSubject.eraseToAnyPublisher()
  }
}

// MARK: - Subjects
private extension UIViewController {
  var viewDidLoadSubject: PassthroughSubject<Void, Never> {
    associatedSubject(key: &viewDidLoadSubjectKey, create: PassthroughSubject<Void, Never>())
  }
  
  var viewWillAppearSubject: PassthroughSubject<Bool, Never> {
    associatedSubject(key: &viewWillAppearSubjectKey, create: PassthroughSubject<Bool, Never>())
  }
  
  var viewDidAppearSubject: PassthroughSubject<Bool, Never> {
    associatedSubject(key: &viewDidAppearSubjectKey, create: PassthroughSubject<Bool, Never>())
  }
  
  var viewWillDisappearSubject: PassthroughSubject<Bool, Never> {
    associatedSubject(key: &viewWillDisappearSubjectKey, create: PassthroughSubject<Bool, Never>())
  }
  
  var viewDidDisappearSubject: PassthroughSubject<Bool, Never> {
    associatedSubject(key: &viewDidDisappearSubjectKey, create: PassthroughSubject<Bool, Never>())
  }
  
  var viewWillLayoutSubviewsSubject: PassthroughSubject<Void, Never> {
    associatedSubject(key: &viewWillLayoutSubviewsSubjectKey, create: PassthroughSubject<Void, Never>())
  }
  
  var viewDidLayoutSubviewsSubject: PassthroughSubject<Void, Never> {
    associatedSubject(key: &viewDidLayoutSubviewsSubjectKey, create: PassthroughSubject<Void, Never>())
  }
  
  var willMoveToParentSubject: PassthroughSubject<UIViewController?, Never> {
    associatedSubject(key: &willMoveToParentSubjectKey, create: PassthroughSubject<UIViewController?, Never>())
  }
  
  var didMoveToParentSubject: PassthroughSubject<UIViewController?, Never> {
    associatedSubject(key: &didMoveToParentSubjectKey, create: PassthroughSubject<UIViewController?, Never>())
  }
  
  var didReceiveMemoryWarningSubject: PassthroughSubject<Void, Never> {
    associatedSubject(key: &didReceiveMemoryWarningSubjectKey, create: PassthroughSubject<Void, Never>())
  }
  
  var isDismissingSubject: PassthroughSubject<Bool, Never> {
    associatedSubject(key: &isDismissingSubjectKey, create: PassthroughSubject<Bool, Never>())
  }
}

// MARK: swizzle Methods
extension UIViewController {
  private static var didSwizzle: Bool = false
  
  public static func swizzleLifecycleMethods() {
    guard !didSwizzle else { return }
    didSwizzle = true
    
    swizzle(#selector(viewDidLoad), #selector(swizzled_viewDidLoad))
    swizzle(#selector(viewWillAppear(_:)), #selector(swizzled_viewWillAppear(_:)))
    swizzle(#selector(viewDidAppear(_:)), #selector(swizzled_viewDidAppear(_:)))
    swizzle(#selector(viewWillDisappear(_:)), #selector(swizzled_viewWillDisappear(_:)))
    swizzle(#selector(viewDidDisappear(_:)), #selector(swizzled_viewDidDisappear(_:)))
    swizzle(#selector(viewWillLayoutSubviews), #selector(swizzled_viewWillLayoutSubviews))
    swizzle(#selector(viewDidLayoutSubviews), #selector(swizzled_viewDidLayoutSubviews))
    swizzle(#selector(willMove(toParent:)), #selector(swizzled_willMove(toParent:)))
    swizzle(#selector(didMove(toParent:)), #selector(swizzled_didMove(toParent:)))
    swizzle(#selector(didReceiveMemoryWarning), #selector(swizzled_didReceiveMemoryWarning))
    swizzle(#selector(dismiss(animated:completion:)), #selector(swizzled_dismiss(animated:completion:)))
  }
  
  private static func swizzle(_ original: Selector, _ swizzled: Selector) {
    guard let originalMethod = class_getInstanceMethod(self, original),
          let swizzledMethod = class_getInstanceMethod(self, swizzled) else { return }
    method_exchangeImplementations(originalMethod, swizzledMethod)
  }
  
  private func associatedSubject<T>(
    key: UnsafeRawPointer,
    create: @autoclosure () -> T
  ) -> T {
    if let existing = objc_getAssociatedObject(self, key) as? T {
      return existing
    }
    let newValue = create()
    objc_setAssociatedObject(self, key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    return newValue
  }
}
  
// MARK: - Action
@objc private extension UIViewController {
  func swizzled_viewDidLoad() {
    swizzled_viewDidLoad()
    viewDidLoadSubject.send(())
  }
  
  func swizzled_viewWillAppear(_ animated: Bool) {
    swizzled_viewWillAppear(animated)
    viewWillAppearSubject.send(animated)
  }
  
  func swizzled_viewDidAppear(_ animated: Bool) {
    swizzled_viewDidAppear(animated)
    viewDidAppearSubject.send(animated)
  }
  
  func swizzled_viewWillDisappear(_ animated: Bool) {
    swizzled_viewWillDisappear(animated)
    viewWillDisappearSubject.send(animated)
  }
  
  func swizzled_viewDidDisappear(_ animated: Bool) {
    swizzled_viewDidDisappear(animated)
    viewDidDisappearSubject.send(animated)
  }
  
  func swizzled_viewWillLayoutSubviews() {
    swizzled_viewWillLayoutSubviews()
    viewWillLayoutSubviewsSubject.send(())
  }
  
  func swizzled_viewDidLayoutSubviews() {
    swizzled_viewDidLayoutSubviews()
    viewDidLayoutSubviewsSubject.send(())
  }
  
  func swizzled_willMove(toParent parent: UIViewController?) {
    swizzled_willMove(toParent: parent)
    willMoveToParentSubject.send(parent)
  }
  
  func swizzled_didMove(toParent parent: UIViewController?) {
    swizzled_didMove(toParent: parent)
    didMoveToParentSubject.send(parent)
  }
  
  func swizzled_didReceiveMemoryWarning() {
    swizzled_didReceiveMemoryWarning()
    didReceiveMemoryWarningSubject.send(())
  }
  
  func swizzled_dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
    isDismissingSubject.send(flag)
    swizzled_dismiss(animated: flag, completion: completion)
  }
}
