//
//  ProgramListSlotViewData.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/28/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation



struct ProgramListSlotViewData: Equatable, Hashable {
  
  enum Marker: Equatable {
    case none
    case going
    case upcoming
    case dateString(String)
    
    func isEqual(st: Marker) -> Bool {
      switch (self, st) {
      case let (.dateString(v0),.dateString(v1)):
        return v0 == v1
      case (.none, .none), (.going, .going), (.upcoming, .upcoming):
        return true
      default:
        return false
      }
    }
    
    static func ==(lhs: Marker, rhs: Marker) -> Bool {
      return lhs.isEqual(st: rhs)
    }
  }  
  
  var start: String
  var end: String
  var marker: Marker
  
  init(start: String, end: String, marker: Marker = .none) {
    self.start = start
    self.end = end
    self.marker = marker
  }
  
  var hashValue: Int {
    return start.hashValue ^ end.hashValue
  }
  
  static func ==(lhs: ProgramListSlotViewData, rhs: ProgramListSlotViewData) -> Bool {
    return lhs.start == rhs.start && lhs.end == rhs.end
  }
}
