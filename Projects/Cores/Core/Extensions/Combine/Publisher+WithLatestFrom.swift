//
//  WithLatestFrom.swift
//  Core
//
//  Created by jung on 12/11/25.
//  Copyright © 2025 com.photi. All rights reserved.
//

import Combine

extension Publishers {
  struct WithLatestFrom<Upstream: Publisher, Other: Publisher>: Publisher where Upstream.Failure == Other.Failure {
    typealias Output = (Upstream.Output, Other.Output)
    typealias Failure = Upstream.Failure

    private let upstream: Upstream
    private let other: Other

    init(upstream: Upstream, other: Other) {
      self.upstream = upstream
      self.other = other
    }

    func receive<S: Subscriber>(subscriber: S)
    where S.Failure == Failure, S.Input == Output {
      let merged = mergeStreams(upstream, other)
      let scanned = scanLatest(from: merged)
      scanned.subscribe(subscriber)
    }
  }
}

private extension Publishers.WithLatestFrom {
  enum Event {
    case fromUpstream(Upstream.Output)
    case fromOther(Other.Output)
  }

  struct State {
    var latestUpstream: Upstream.Output?
    var latestOther: Other.Output?
    let shouldEmit: Bool
  }

  // MARK: Merge two streams with event tagging
  func mergeStreams(
    _ upstream: Upstream,
    _ other: Other
  ) -> AnyPublisher<Event, Failure> {
    let pub1 = upstream.map(Event.fromUpstream)
    let pub2 = other.map(Event.fromOther)
    return pub1.merge(with: pub2).eraseToAnyPublisher()
  }

  // MARK: Stateful scan logic (this is the core)
  func scanLatest(
    from merged: AnyPublisher<Event, Failure>
  ) -> AnyPublisher<Output, Failure> {
    merged
      .scan(nil as State?) { previous, event in
        var latestUp = previous?.latestUpstream
        var latestOther = previous?.latestOther
        var shouldEmit = false

        switch event {
          case .fromUpstream(let value):
            latestUp = value
            shouldEmit = (latestOther != nil)

          case .fromOther(let value):
            latestOther = value
            shouldEmit = false
        }

        return State(latestUpstream: latestUp,
                     latestOther: latestOther,
                     shouldEmit: shouldEmit)
      }
      .compactMap { $0 }
      .filter { $0.shouldEmit }
      .map { state in
        // Both values guaranteed to be non-nil after filter
        (state.latestUpstream!, state.latestOther!)
      }
      .eraseToAnyPublisher()
  }
}
