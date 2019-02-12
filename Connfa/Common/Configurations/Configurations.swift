//
//  Configurations.swift
//  Connfa
//
//  Created by Marian Fedyk on 7/26/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit

class Configurations {
  private var fileUrl = Bundle.main.url(forResource: Constants.PList.fileResourse , withExtension: Constants.PList.fileExtension)!
  
  var twitterApiKey: String? {
    return valueFor(outerKey: Constants.PList.Twitter.outerDictionaryKey, innerKey: Constants.PList.Twitter.twitterAPIKey)
  }
  
  var twitterApiSecret: String? {
    return valueFor(outerKey: Constants.PList.Twitter.outerDictionaryKey, innerKey: Constants.PList.Twitter.twitterApiSecret)
  }
  
  var twitterSearchQuery: String? {
    return valueFor(outerKey: Constants.PList.Twitter.outerDictionaryKey, innerKey: Constants.PList.Twitter.twitterSearchQuery)
  }
  
  var tintColor: UIColor {
    return UIColor(hexString: valueFor(outerKey: Constants.PList.Colors.outerDictionaryKey, innerKey: Constants.PList.Colors.tintColor) ?? "")
  }
  
  var timeZoneIdentifier: String {
    return valueFor(outerKey: Constants.PList.Date.outerDictionaryKey, innerKey: Constants.PList.Date.timeZoneIdentifier) ?? TimeZone.current.identifier
  }
  
  var startDate: String {
    let date: Date = valueFor(outerKey: Constants.PList.Date.outerDictionaryKey, innerKey: Constants.PList.Date.startDate)!
    let formatter = DateFormatter.default
    formatter.dateFormat = "MM-dd-yyyy"
    return formatter.string(from: date)
  }
  
  var calendarName: String? {
    return valueFor(outerKey: Constants.PList.Title.outerDictionaryKey, innerKey: Constants.PList.Title.calendarName)
  }
  
  private func valueFor<T>(outerKey: String, innerKey: String) -> T? {
    if let data = try? Data(contentsOf: fileUrl) {
      if let outerDictionary = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
        if let innerDictionary = outerDictionary?[outerKey] as? [String: Any] {
          return innerDictionary[innerKey] as? T
        }
      }
    }
    return nil
  }
}
