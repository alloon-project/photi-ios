//
//  AppContainer.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import DataMapper
import LogIn
import LogInImpl
import Repository
import RepositoryImpl
import UseCase
import UseCaseImpl

final class AppDependency: Dependency { }

protocol AppContainable: Containable {
  func coordinator() -> Coordinating
}

final class AppContainer:
  Container<AppDependency>,
  AppContainable,
  MainDependency,
  LogInDependency,
  SignUpDependency {
  func coordinator() -> Coordinating {
    return AppCoordinator(
      mainContainer: MainContainer(dependency: self),
      logInContainer: LogInContainer(dependency: self)
    )
  }
  
  // MARK: - Containable
  lazy var signUpContainable: SignUpContainable = {
    return SignUpContainer(dependency: self)
  }()
  
  // MARK: - UseCase
  lazy var logInUseCase: LogInUseCase = {
    return LogInUseCaseImpl(repository: logInRepository)
  }()
  
  lazy var signUpUseCase: SignUpUseCase = {
    return SignUpUseCaseImpl(repository: signUpRepository)
  }()
  
  // MARK: - Repository
  lazy var logInRepository: LogInRepository = {
    return LogInRepositoryImpl(dataMapper: LogInDataMapperImpl())
  }()
  
  lazy var signUpRepository: SignUpRepository = {
    return SignUpRepositoryImpl(dataMapper: SignUpDataMapperImpl())
  }()
}
