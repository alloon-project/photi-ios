//
//  UIControl+Extension.swift
//  Core
//
//  Created by jung on 11/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import UIKit
import Combine

public extension UIControl {
  func eventPublisher(for events: UIControl.Event) -> AnyPublisher<Void, Never> {
    EventPublisher(control: self, events: events)
      .receive(on: RunLoop.main)
      .eraseToAnyPublisher()
  }
  
  struct EventPublisher: Publisher {
    public typealias Output = Void
    public typealias Failure = Never
    let control: UIControl
    let events: UIControl.Event
    
    public func receive<S: Subscriber>(subscriber: S) where S.Input == Output, S.Failure == Failure {
      subscriber.receive(subscription: EventSubscription(subscriber: subscriber, control: control, events: events))
    }
  }
  
  private final class EventSubscription<S: Subscriber>: Subscription where S.Input == Void, S.Failure == Never {
    private var sub: S?
    
    weak var control: UIControl?
    let events: UIControl.Event
    
    init(subscriber: S, control: UIControl, events: UIControl.Event) {
      self.sub = subscriber; self.control = control; self.events = events
      control.addTarget(self, action: #selector(handle), for: events)
    }
    
    func request(_ demand: Subscribers.Demand) {}
    
    func cancel() {
      control?.removeTarget(self, action: #selector(handle), for: events)
      sub = nil
    }
    
    @objc private func handle() {
      _ = sub?.receive(())
    }
  }
}
