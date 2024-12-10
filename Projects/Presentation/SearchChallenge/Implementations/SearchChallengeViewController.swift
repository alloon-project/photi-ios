//
//  SearchChallengeViewController.swift
//  SearchChallengeImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import UIKit
import DesignSystem
import RxCocoa
import RxSwift
import SnapKit

final class SearchChallengeViewController: UIViewController {
  private let segment = PhotiSegmentControl()
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    segment.items = ["1번", "2번", "3번"]
    view.addSubview(segment)
    view.backgroundColor = .gray200
    segment.snp.makeConstraints {
      $0.center.equalToSuperview()
      $0.height.equalTo(50)
      $0.width.equalTo(380)
    }
    
    segment.rx.selectedSegment
      .bind { segment in
        print(segment)
      }
      .disposed(by: disposeBag)
  }
}
