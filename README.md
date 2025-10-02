<h1 align="center">
<img src="https://github.com/user-attachments/assets/7e77a0ab-30ef-4e2e-a918-5b061bad157f" alt="photi logo" width="28">
  &nbsp;포티 - photi
</h1>
<p align="center">
  <img alt="UIKit" src="https://img.shields.io/badge/UIKit-0A84FF">
  <img alt="Tuist" src="https://img.shields.io/badge/Tuist-0B5FFF">
  <img alt="Clean Architecture" src="https://img.shields.io/badge/Clean%20Architecture-4B8BBE">
  <img alt="RxSwift" src="https://img.shields.io/badge/RxSwift-FF2D55?logo=reactivex&logoColor=white">
  <img alt="Fastlane" src="https://img.shields.io/badge/Fastlane-00F2A9?logo=fastlane&logoColor=white">
</p>

<p align="center">
<b>포티(photi)</b>는 Photo + Post-it에서 온 이름의 인증형 소셜 챌린지 앱입니다. <br>
하루 한 번의 즉석 인증으로 기록을 가볍게 쌓고, 해시태그/검색·파티·댓글/좋아요로 동기부여를 강화합니다.<br>
작고 단순한 규칙으로 습관 형성을 돕고, 공개/초대 코드 챌린지와 외부 공유를 지원합니다.<br>
</p>


## 기능 소개 
|챌린지 생성|챌린지 인증|챌린지 공유|파티원과 함께 도전 |
|:---:|:---:|:---:|:---:|
|<img src = "https://github.com/user-attachments/assets/82697c93-4045-44ba-a098-3c2408cfff5f" width="200"/>|<img src = "https://github.com/user-attachments/assets/99b9244a-303b-4c1a-afa2-ec22c7f9b7a5" width="200"/>|<img src = "https://github.com/user-attachments/assets/eb34d5a3-9771-476a-a114-4da5f7e4db6e" width="200"/>|<img src = "https://github.com/user-attachments/assets/d40d3e63-66b7-4c19-8d2c-a9ed959668c0" width="200"/>|
<details>
<summary>기능 상세 소개</summary>
<div markdown="1">

### 1일 1인증 📷

하루 한 번, 정해진 시간 안에 즉석 사진으로 인증해요. <br>
매일 쌓이는 기록이 다음 도전을 만드는 동력이 됩니다.

### 챌린지 만들기 🧩

목표·인증 시간·간단한 규칙만 정하면 바로 시작!
초대 코드를 활용해 친구들과 프라이빗 챌린지도 즐길 수 있어요.

### 다양한 챌린지 탐색  🔎

해시태그/검색으로 취향에 맞는 챌린지를 발견하세요.
인기 챌린지로 요즘 유행 중인 도전도 한눈에 확인!

### 파티원과 함께 도전하기 👯‍♀️

파티원과 사진을 공유하고 좋아요/댓글로 응원해요.
나만의 목표 메모를 남겨 서로 동기부여를 높여보세요.

### 인증 사진 공유하기 📲

인스타그램 등 소셜로 나의 챌린지 기록을 손쉽게 공유하고,
더 많은 사람들과 도전의 즐거움을 나눠보세요.
</div>
</details>



## 아키텍쳐
### 프로젝트 구성
**App 🚀** <br>
앱의 엔트리 포인트이자, DI Composition Root 역할을 하는 계층/모듈

**Presentation 🎨** <br>
각 서비스(도메인) 별로 모듈을 분리하여, App 혹은 Presentation 내부에서 조합해 쓰는 UI 계층

**Domain 🧠** <br>
Entity, UseCase로 구성된 비즈니스 로직의 핵심 계층
- Entity: 앱 비즈니스 모델 정의하는 모듈
- UseCase: 시나리오 단위 도메인 로직을 구현한 모듈

**Data 🌐** <br>
Domain에서 정의한 계약(Repository 인터페이스)을 구현하는 데이터 접근 계층
- Repository: Domain UseCase가 의존하는 인터페이스 구현체를 담은 모듈
- DataMapper: DTO ↔ Entity 변환 담당하는 모듈
- PhotiNetwork: 외부 라이브러리 없이 `URLSession`을 추상화한 Endpoint 중심 네트워크 모듈
  - 다양한 HTTP 메서드를 일관된 방식으로 제공
  - Access Token 만료 시 Refresh Token을 통한 자동 재발급 & 원 요청 재시도 처리

**Core 🧰** <br>
앱 전역에서 재사용되는 Util·Extension 모음

**DesignSystem 🧩** <br>
앱 내 사용하는 폰트, 컬러, 이미지 등의 에셋과 공통 디자인 컴포넌트가 있는 모듈

### Presentation 구조도 
패턴: MVVM + Coordinator
- Coordinator: 화면 전환 및 라우팅 책임을 분리한 구조
  -  현재는 별도 SPM 패키지로 분리하여 관리
  -  👉 [Coordinator SPM 바로가기](https://github.com/jungseokyoung-cloud/Coordinator)
<img width="2211" height="1191" alt="Image" src="https://github.com/user-attachments/assets/82abd8f6-4e7b-4fc9-9416-497ac4d7dd9d" />
