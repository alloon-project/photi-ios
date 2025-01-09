//
//  ViewableCoordinator.swift
//  Core
//
//  Created by jung on 1/7/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import RxSwift

public protocol ViewableCoordinating: Coordinating {
  var viewControllerable: ViewControllerable { get }
}

/// `ViewController`가 있는 경우, 화면 전환 로직을 담당하는 객체입니다.
open class ViewableCoordinator<PresenterType>: Coordinator, ViewableCoordinating {
  private let disposeBag = DisposeBag()
  
  /// push, present 등등 라우팅 역할을 담당하는 `ViewController`입니다.
  public let viewControllerable: ViewControllerable
  /// 내부적으로 `Coordinator`에서 `ViewController`로 이벤트를 전달할 경우 사용합니다.
  public let presenter: PresenterType
  
  public init(_ viewController: ViewControllerable) {
    self.viewControllerable = viewController
    
    guard let presenter = viewController as? PresenterType else {
      fatalError("\(viewController) should conform to \(PresenterType.self)")
    }
    
    self.presenter = presenter
    super.init()
    bind()
  }
  
  /// `ViewController`가 로드가 완료된 시점에 호출됩니다.
  open func viewDidLoad() { }
  
  /// `ViewController`가 화면에 Display가 완료된 시점에 호출됩니다.
  open func viewDidAppear() { }
}

// MARK: - Private Methods
private extension ViewableCoordinator {
  func bind() {
    viewControllerable.uiviewController.rx.viewDidLoad
      .subscribe(with: self) { owner, _ in
        owner.viewDidLoad()
      }
      .disposed(by: disposeBag)
    
    viewControllerable.uiviewController.rx.viewDidAppear
      .subscribe(with: self) { owner, _ in
        owner.viewDidAppear()
      }
      .disposed(by: disposeBag)
  }
}
