//
//  ProgramListFilterAdapter.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/28/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

class ProgramListFilterAdapter {
  
  let replacements: [String:String] = ["Session" : "Sessions",
                                       "BoF" : "BoFs",
                                       "SE" : "Social Events (SE)",
                                       "Social Event" : "Social Events (SE)"]
  
  public func adapted(_ title: String) -> String {
    for (key, value) in replacements {
      if title == key {
        return title.replacingOccurrences(of: key, with: value)
      }
    }
    return title
  }
  
  public func fullString(types: [String], specialTypeMarked: Bool, levels: [String], tracks: [String]) -> String {
    var result = ""
    
    types.forEach { (info) in
      if !result.isEmpty {
        result += ", "
      }
      result += self.adapted(info)
    }
    
    
      var colonNeeded = true
      levels.forEach { (info) in
        if colonNeeded {
            result += !result.isEmpty ? ": " : "Level: "
          colonNeeded = false
        } else {
          result += ", "
        }
        result += self.adapted(info)
      }
    
    var semiNeeded = !result.isEmpty
    tracks.forEach { (info) in
      result += !result.isEmpty ? semiNeeded ? "; " : ", " : ""
      semiNeeded = false
      result += self.adapted(info)
    }
    
    return result
  }
}
