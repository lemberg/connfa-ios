//
//  ProgramListDayViewData.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/28/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

struct ProgramListDayViewData: Equatable, Hashable {  
  var origin: Date
  var day: String
  var fullDate: String
  
  init(_ origin: Date, dayFormatter: DateFormatter, fullFormatter: DateFormatter) {
    self.origin = origin
    self.day = dayFormatter.string(from: origin)
    self.fullDate = fullFormatter.string(from: origin)
  }
  
  var hashValue: Int {
    return fullDate.hashValue
  }
  
  static func ==(lhs: ProgramListDayViewData, rhs: ProgramListDayViewData) -> Bool {
    return lhs.fullDate == rhs.fullDate
  }
}
