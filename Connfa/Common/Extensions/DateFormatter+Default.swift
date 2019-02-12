//
//  DateFormatter+default.swift
//  ConnfaCore
//
//  Created by Marian Fedyk on 8/28/17.
//

import Foundation

let defaultFormatter = DateFormatter.default

extension DateFormatter {
  static var `default`: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    formatter.locale = Locale(identifier: "en_US")
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    return formatter
  }
}


