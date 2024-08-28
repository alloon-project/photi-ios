//
//  InquiryViewModel.swift
//  HomeImpl
//
//  Created by 임우섭 on 8/28/24.
//  Copyright © 2024 com.photi. All rights reserved.
//

import RxCocoa
import RxSwift
import DesignSystem

protocol InquiryCoordinatable: AnyObject { }

protocol InquiryViewModelType: InquiryViewModelable {
  associatedtype Input
  associatedtype Output
  
  var disposeBag: DisposeBag { get }
  var coordinator: InquiryCoordinatable? { get set }
  
  func transform(input: Input) -> Output
}

final class InquiryViewModel: InquiryViewModelType {
  let disposeBag = DisposeBag()
  
  weak var coordinator: InquiryCoordinatable?
  
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
