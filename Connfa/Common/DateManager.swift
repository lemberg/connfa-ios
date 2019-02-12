//
//  DateManager.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/19/17.
//

import Foundation

class DateManager {
  static func programDetailsDateString(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: Configurations().timeZoneIdentifier)
    dateFormatter.dateFormat = "EEEE - MMMM d"
    return dateFormatter.string(from: date)
  }
  
  static func programDetailsTimeIntervalString(first: Date, second: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.timeZone = TimeZone(identifier: Configurations().timeZoneIdentifier)
    dateFormatter.dateFormat = "hh:mm a"
    return "\(dateFormatter.string(from: first)) - \(dateFormatter.string(from: second))"
  }
}

