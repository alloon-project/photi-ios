//
//  Coordinator.swift
//  Core
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit

/// 부모 Coordinator에게 요청하는 메서드를 구현하면 됩니다.
public protocol CoordinatorListener: AnyObject { }

/// 화면 전환 로직 및, `ViewController`와 `ViewModel`생성을 담당하는 객체입니다.
public protocol Coordinating: AnyObject {
  var navigationController: UINavigationController? { get set }
  var children: [Coordinating] { get }
  
  func start(at navigationController: UINavigationController?)
  func stop()
  func addChild(_ coordinator: Coordinating)
  func removeChild(_ coordinator: Coordinating)
}

open class Coordinater: Coordinating {
  public var navigationController: UINavigationController?
  public final var children: [Coordinating] = []
  
  public init() { }
  
  public init(_ navigationController: UINavigationController?) {
    self.navigationController = navigationController
  }
  
  /**
   `Coordinator`는 해당 메서드를 반드시 override해야 합니다.
   
   override에선 `navigationController`에 추가하는 로직을 구현해야 합니다.
   ```swift
   override func start() {
   super.start()
   navigationController.pushViewController(self.viewController, animated: true)
   }
   ```
   */
  open func start(at navigationController: UINavigationController?) {
    self.navigationController = navigationController
  }
  
  /// deinit 직전에 원하는 동작이 있을 때, 해당 메서드에 구현하면 됩니다.
  open func stop() { 
    self.navigationController = nil
  }
  
  public final func addChild(_ coordinator: Coordinating) {
    guard !children.contains(where: { $0 === coordinator }) else { return }
    
    children.append(coordinator)
  }
  
  public final func removeChild(_ coordinator: Coordinating) {
    guard let index = children.firstIndex(where: { $0 === coordinator }) else { return }
    
    children.remove(at: index)
  }
  
  private func removeAllChild() {
    children.forEach { removeChild($0) }
  }
 
  deinit {
    self.stop()
    if !children.isEmpty {
      self.removeAllChild()
    }
  }
}
