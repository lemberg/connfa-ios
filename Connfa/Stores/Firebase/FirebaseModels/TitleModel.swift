//
//  TitleModel.swift
//  Connfa
//
//  Created by Marian Fedyk on 2/13/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation

class TitleModel: FirebaseModel {
  
  static var keyPath: String {
    return Keys.title
  }
  
  static var notification: Notification.Name? {
    return .receiveTitle
  }
  
  var id: String!
  var titleMajor: String!
  var titleMinor: String!
  
  required init?(dictionary: SnapshotDictionary, key: String) {
    guard let dict = dictionary,
      let titleMajor = dict[Keys.Title.titleMajor] as? String,
      let titleMinor = dict[Keys.Title.titleMinor] as? String
      else { return nil }
    self.id = key
    self.titleMajor = titleMajor
    self.titleMinor = titleMinor
  }
}
