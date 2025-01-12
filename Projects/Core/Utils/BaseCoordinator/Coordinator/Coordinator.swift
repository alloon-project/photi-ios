//
//  Coordinator.swift
//  Core
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

/// 화면 전환 로직을 담당하는 객체입니다..
public protocol Coordinating: AnyObject {
  var children: [Coordinating] { get }
  
  func start()
  func stop()
  func addChild(_ coordinator: Coordinating)
  func removeChild(_ coordinator: Coordinating)
}

open class Coordinator: Coordinating {
  public final var children: [Coordinating] = []
    
  /// 부모에게 attach되었을 때 원하는 동작을 해당 메서드에 구현하면 됩니다.
  open func start() { }
  
  /// 부모에게 제거되었을 때 원하는 동작을 해당 메서드에 구현하면 됩니다.
  open func stop() {
    self.removeAllChild()
  }
  
  public init() { }
  
  public final func addChild(_ coordinator: Coordinating) {
    guard !children.contains(where: { $0 === coordinator }) else { return }
    
    children.append(coordinator)
    
    coordinator.start()
  }
  
  public final func removeChild(_ coordinator: Coordinating) {
    guard let index = children.firstIndex(where: { $0 === coordinator }) else { return }
    
    children.remove(at: index)
    
    coordinator.stop()
  }
  
  private func removeAllChild() {
    children.forEach { removeChild($0) }
  }
}
