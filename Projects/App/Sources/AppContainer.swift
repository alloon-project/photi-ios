//
//  AppContainer.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Core
import DataMapper
import Home
import HomeImpl
import LogIn
import LogInImpl
import MyPage
import MyPageImpl
import Repository
import RepositoryImpl
import SearchChallenge
import SearchChallengeImpl
import UseCase
import UseCaseImpl

final class AppDependency: Dependency { }

protocol AppContainable: Containable {
  func coordinator() -> Coordinating
}

final class AppContainer:
  Container<AppDependency>,
  AppContainable,
  LogInDependency,
  SignUpDependency,
  HomeDependency,
  SearchChallengeDependency,
  MyPageDependency {
  func coordinator() -> Coordinating {
    let home = HomeContainer(dependency: self)
    let searchChallenge = SearchChallengeContainer(dependency: self)
    let myPage = MyPageContainer(dependency: self)
    
    return AppCoordinator(
      homeContainable: home,
      searchChallengeContainable: searchChallenge,
      myPageContainable: myPage
    )
  }
  
  // MARK: - Containable
  lazy var loginContainable: LogInContainable = {
    return LogInContainer(dependency: self)
  }()
  
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
  
  lazy var homeUseCae: HomeUseCase = {
    return HomeUseCaseImpl(repository: challengeRepository)
  }()
  
  // MARK: - Repository
  lazy var logInRepository: LogInRepository = {
    return LogInRepositoryImpl(dataMapper: LogInDataMapperImpl())
  }()
  
  lazy var signUpRepository: SignUpRepository = {
    return SignUpRepositoryImpl(dataMapper: SignUpDataMapperImpl())
  }()
  
  lazy var challengeRepository: ChallengeRepository = {
    return ChallengeRepositoryImpl(dataMapper: ChallengeDataMapperImpl())
  }()
}
