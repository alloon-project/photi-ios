//
//  Publisher.swift
//  Core
//
//  Created by jung on 11/2/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Foundation
import Combine

// MARK: - sink (weak owner)
// Publisher 값을 구독할 때 owner를 약하게 참조하는 헬퍼
public extension Publisher where Failure == Never {
  /// 값을 구독하며, owner를 약한 참조
  func sink<Owner: AnyObject>(
    with owner: Owner,
    _ transform: @escaping (Owner, Output) -> Void
  ) -> AnyCancellable where Failure == Never {
    sink { [weak owner] value in
      guard let owner else { return }
      transform(owner, value)
    }
  }
  
  /// 완료/에러까지 함께 구독하며, owner를 약한 참조
  @discardableResult
  func sink<Owner: AnyObject>(
    with owner: Owner,
    receiveCompletion: @escaping (Owner, Subscribers.Completion<Failure>) -> Void,
    receiveValue: @escaping (Owner, Output) -> Void
  ) -> AnyCancellable {
    sink(
      receiveCompletion: { [weak owner] completion in
        guard let owner else { return }
        receiveCompletion(owner, completion)
      },
      receiveValue: { [weak owner] value in
        guard let owner else { return }
        receiveValue(owner, value)
      }
    )
  }
}

// MARK: - UI 업데이트용 sink / bind
// 메인 스레드에서 안전하게 UI 갱신을 보장
public extension Publisher where Failure == Never {
  /// 메인 스레드에서 값 구독 (owner 약한 참조)
  @discardableResult
  func sinkOnMain<Owner: AnyObject>(
    with owner: Owner,
    _ receiveValue: @escaping (Owner, Output) -> Void
  ) -> AnyCancellable {
    receive(on: RunLoop.main)
      .sink { [weak owner] value in
        guard let owner else { return }
        receiveValue(owner, value)
      }
  }
  
  /// 메인 스레드에서 값 구독 (owner 약한 참조)
  @discardableResult
  func bind<Owner: AnyObject>(
    to keyPath: ReferenceWritableKeyPath<Owner, Output>,
    on owner: Owner
  ) -> AnyCancellable {
    receive(on: RunLoop.main)
      .sink { [weak owner] value in
        owner?[keyPath: keyPath] = value
      }
  }
}

// MARK: - With Latest From
public extension Publisher where Failure == Never {
  /// source가 emit할 때마다 other의 "가장 최근 값"을 내보냄
  /// other가 아직 값을 낸 적이 없으면 대기 (Rx와 동일)
  func withLatestFrom<Other: Publisher>(
    _ other: Other
  ) -> AnyPublisher<Other.Output, Never> where Other.Failure == Never {
    return Publishers.WithLatestFrom(upstream: self, other: other)
      .map { $0.1 }
      .eraseToAnyPublisher()
  }

  /// withLatestFrom + selector (source의 값과 other 최신값을 조합)
  func withLatestFrom<Other: Publisher, R>(
    _ other: Other,
    _ transform: @escaping (Output, Other.Output) -> R
  ) -> AnyPublisher<R, Never> where Other.Failure == Never {
    return Publishers.WithLatestFrom(upstream: self, other: other)
      .map { transform($0.0, $0.1) }
      .eraseToAnyPublisher()
  }
}

// swiftlint:disable large_tuple
// MARK: - Combine Latest
public extension Publisher where Failure == Never {
  /// 두 Publisher의 최신 값을 결합하여 튜플 형태로 방출합니다.
  func combineLatest<P1: Publisher>(_ other: P1) -> AnyPublisher<(Output, P1.Output), Never>
  where P1.Failure == Never {
    Publishers.CombineLatest(self, other).eraseToAnyPublisher()
  }

  /// 두 Publisher의 최신 값을 받아 변환(transform) 결과를 방출합니다.
  func combineLatest<P1: Publisher, R>(
    _ other: P1,
    _ transform: @escaping (Output, P1.Output) -> R
  ) -> AnyPublisher<R, Never> where P1.Failure == Never {
    self.combineLatest(other)
      .map(transform)
      .eraseToAnyPublisher()
  }

  /// 세 Publisher의 최신 값을 결합하여 튜플 형태로 방출합니다.
  func combineLatest<P1: Publisher, P2: Publisher>(
    _ other1: P1,
    _ other2: P2
  ) -> AnyPublisher<(Output, P1.Output, P2.Output), Never>
  where P1.Failure == Never, P2.Failure == Never {
    self.combineLatest(other1)
      .combineLatest(other2)
      .map { pair, output in (pair.0, pair.1, output) }
      .eraseToAnyPublisher()
  }
  
  /// 세 Publisher의 최신 값을 받아 변환(transform) 결과를 방출합니다.
  func combineLatest<P1: Publisher, P2: Publisher, R>(
    _ other1: P1,
    _ other2: P2,
    _ transform: @escaping (Output, P1.Output, P2.Output) -> R
  ) -> AnyPublisher<R, Never>
  where P1.Failure == Never, P2.Failure == Never {
    self.combineLatest(other1, other2)
      .map(transform)
      .eraseToAnyPublisher()
  }
}
// swiftlint:enable large_tuple
