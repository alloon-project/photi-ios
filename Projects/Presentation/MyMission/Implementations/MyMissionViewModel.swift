//
//  MyMissionViewModel.swift
//  MyMissionImpl
//
//  Created by jung on 6/29/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol MyMissionCoordinatable: AnyObject { }

protocol MyMissionViewModelType: AnyObject, MyMissionViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: MyMissionCoordinatable? { get set }
}

final class MyMissionViewModel: MyMissionViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: MyMissionCoordinatable?
  
  // MARK: - Input
  struct Input { }
  
  // MARK: - Output
  struct Output { }
  
  // MARK: - Initializers
  init() { }
  
  func transform(input: Input) -> Output {
    return Output()
  }
}
