//
//  AppContainer.swift
//  Alloon
//
//  Created by jung on 4/14/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Challenge
import ChallengeImpl
import Core
import DataMapper
import Home
import HomeImpl
import LogIn
import LogInImpl
import MyPage
import MyPageImpl
import Report
import ReportImpl
import Repository
import RepositoryImpl
import SearchChallenge
import SearchChallengeImpl
import UseCase
import UseCaseImpl

final class AppDependency: Dependency { }

protocol AppContainable: Containable {
  func coordinator() -> ViewableCoordinating
}

final class AppContainer:
  Container<AppDependency>,
  AppContainable,
  LogInDependency,
  ResetPasswordDependency,
  HomeDependency,
  SearchChallengeDependency,
  MyPageDependency,
  ReportDependency,
  ChallengeDependency,
  NoneMemberChallengeDependency,
  ChallengeOrganizeDependency {
  func coordinator() -> ViewableCoordinating {
    let viewModel = AppViewModel(useCase: AppUseCaseImpl(repository: authRepository))
    let viewControllerable = AppViewController(viewModel: viewModel)
    
    let home = HomeContainer(dependency: self)
    let searchChallenge = SearchChallengeContainer(dependency: self)
    let myPage = MyPageContainer(dependency: self)
    
    let coordinator = AppCoordinator(
      viewControllerable: viewControllerable,
      homeContainable: home,
      searchChallengeContainable: searchChallenge,
      myPageContainable: myPage,
      loginContainable: loginContainable
    )
    viewModel.coordinator = coordinator

    return coordinator
  }
  
  // MARK: - Containable
  lazy var loginContainable: LogInContainable = {
    return LogInContainer(dependency: self)
  }()
  
  lazy var resetPasswordContainable: ResetPasswordContainable = {
    return ResetPasswordContainer(dependency: self)
  }()
  
  lazy var challengeOrganizeContainable: ChallengeOrganizeContainable = {
    return ChallengeOrganizeContainer(dependency: self)
  }()
  
  lazy var reportContainable: ReportContainable = {
    return ReportContainer(dependency: self)
  }()
  
  lazy var challengeContainable: ChallengeContainable = {
    return ChallengeContainer(dependency: self)
  }()
  
  lazy var noneMemberChallengeContainable: NoneMemberChallengeContainable = {
    return NoneMemberChallengeContainer(dependency: self)
  }()
  
  // MARK: - UseCase
  lazy var logInUseCase: LogInUseCase = {
    return LogInUseCaseImpl(
      authRepository: authRepository,
      loginrepository: logInRepository
    )
  }()
  
  lazy var signUpUseCase: SignUpUseCase = {
    return SignUpUseCaseImpl(repository: signUpRepository)
  }()
  
  lazy var myPageUseCase: MyPageUseCase = {
    return MyPageUseCaseImpl(
      authRepository: authRepository,
      myPagerepository: myPageRepository
    )
  }()
  
  lazy var profileEditUseCase: ProfileEditUseCase = {
    return ProfileEditUseCaseImpl(
      authRepository: authRepository,
      loginRepository: logInRepository,
      myPageRepository: myPageRepository
    )
  }()
  
  lazy var homeUseCae: HomeUseCase = {
    return HomeUseCaseImpl(challengeRepository: challengeRepository)
  }()
  
  var challengeUseCase: ChallengeUseCase {
    return ChallengeUseCaseImpl(
      challengeRepository: challengeRepository,
      feedRepository: feedRepository,
      authRepository: authRepository
    )
  }
  
  var feedUseCase: FeedUseCase {
    return FeedUseCaseImpl(repository: feedRepository)
  }
  
  lazy var searchUseCase: SearchUseCase = {
    return SearchUseCaseImpl(
      challengeRepository: challengeRepository,
      searchHistoryRepository: searchHistoryRepository,
      authRepository: authRepository
    )
  }()
  
  lazy var reportUseCase: ReportUseCase = {
    return ReportUseCaseImpl(repository: reportRepository)
  }()
  
  lazy var inquiryUseCase: InquiryUseCase = {
    return InquiryUseCaseImpl(repository: inquiryRepository)
  }()
  
  lazy var organizeUseCase: OrganizeUseCase = {
    return OrganizeUseCaseImpl(repository: organizeRepository)
  }()
  
  // MARK: - Repository
  lazy var authRepository: AuthRepository = {
    return AuthRepositoryImpl()
  }()
  
  lazy var logInRepository: LogInRepository = {
    return LogInRepositoryImpl(dataMapper: LogInDataMapperImpl())
  }()

  lazy var signUpRepository: SignUpRepository = {
    return SignUpRepositoryImpl(dataMapper: SignUpDataMapperImpl())
  }()
  
  lazy var myPageRepository: MyPageRepository = {
    return MyPageRepositoyImpl(dataMapper: MyPageDataMapperImpl())
  }()
  
  lazy var challengeRepository: ChallengeRepository = {
    return ChallengeRepositoryImpl(dataMapper: ChallengeDataMapperImpl())
  }()
  
  lazy var feedRepository: FeedRepository = {
    return FeedRepositoryImpl(dataMapper: ChallengeDataMapperImpl())
  }()
  
  lazy var reportRepository: ReportRepository = {
    return ReportRepositoryImpl(dataMapper: ReportDataMapperImpl())
  }()
  
  lazy var inquiryRepository: InquiryRepository = {
    return InquiryRepositoryImpl(dataMapper: InquiryDataMapperImpl())
  }()
  
  lazy var organizeRepository: ChallengeOrganizeRepository = {
    return ChallengeOrganizeRepositoryImpl(dataMapper: ChallengeOrganizeDataMapperImpl())
  }()
  
  lazy var searchHistoryRepository: SearchHistoryRepository = {
    return SearchHistoryRepositoryImpl()
  }()
}
