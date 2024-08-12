//
//  CalendarDate.swift
//  DesignSystem
//
//  Created by jung on 5/13/24.
//  Copyright © 2024 com.alloon. All rights reserved.
//

import Foundation

/// 날짜의 타입입니다.
enum DateType {
  /// 시작 날짜
  case startDate
  /// 선택이 가능한 날짜
  case `default`
  /// 선택이 불가능한 날짜
  case disabled
}

struct CalendarDate {
  var year: Int
  var month: Int
  var day: Int
  var type: DateType
  
  var date: Date {
    let string = "\(year)-\(month)-\(day)"
    let dateFormatter = DateFormatter()

    dateFormatter.dateFormat = "yyyy-MM-dd"
    let date = dateFormatter.date(from: string) ?? .now
    return date
  }
}

// MARK: - Initalizers
extension CalendarDate {
  init(date: Date) {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    
    self.year = components.year ?? 0
    self.month = components.month ?? 0
    self.day = components.day ?? 0
    self.type = .default
  }
  
  init(yearAndMonth: CalendarDate, day: Int, type: DateType) {
    self.year = yearAndMonth.year
    self.month = yearAndMonth.month
    self.day = day
    self.type = type
  }
}

// MARK: - Methods
extension CalendarDate {
  /// 다음날짜의 `CalendarDate`를 리턴합니다.
  func nextDay() -> CalendarDate {
    if day == self.daysOfMonth() {
      return nextMonth()
    } else {
      return CalendarDate(year: year, month: month, day: day + 1, type: type)
    }
  }
  
  /// 다음달의 `CalendarDate`를 리턴합니다.
  func nextMonth() -> CalendarDate {
    if month == 12 {
      return CalendarDate(year: year + 1, month: 1, day: day, type: type)
    } else {
      return CalendarDate(year: year, month: month + 1, day: day, type: type)
    }
  }
  
  /// 이전달의 `CalendarDate`를 리턴합니다.
  func previousMonth() -> CalendarDate {
    if month == 1 {
      return CalendarDate(year: year - 1, month: 12, day: day, type: type)
    } else {
      return CalendarDate(year: year, month: month - 1, day: day, type: type)
    }
  }
  
  /// 현재 `Date`가 paramter의 `date`보다 더 작다면 true를 리턴합니다.
  func compareYearAndMonth(with date: CalendarDate) -> Bool {
    if year < date.year {
      return true
    } else if year == date.year && month <= date.month {
      return true
    } else {
      return false
    }
  }
  
  /// `year`, `month`의 첫번째 요일을 정수형으로 리턴합니다.
  func startDayOfWeek() -> Int {
    let calendar = Calendar.current
    let components = DateComponents(year: year, month: month)
    let date = calendar.date(from: components) ?? Date()
    
    return calendar.component(.weekday, from: date) - 1
  }
  
  /// `year`, `month`의 총 날짜 수를 리턴합니다.
  func daysOfMonth() -> Int {
    let calendar = Calendar.current
    let components = DateComponents(year: year, month: month)
    let date = calendar.date(from: components) ?? Date()
    
    return calendar.range(of: .day, in: .month, for: date)?.count ?? 0
  }
}

// MARK: - Comparable
extension CalendarDate: Comparable {
  static func < (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
    if lhs.year != rhs.year {
      return lhs.year < rhs.year
    } else if lhs.month != rhs.month {
      return lhs.month < rhs.month
    } else {
      return lhs.day < rhs.day
    }
  }
  
  static func == (lhs: CalendarDate, rhs: CalendarDate) -> Bool {
    return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
  }
}
