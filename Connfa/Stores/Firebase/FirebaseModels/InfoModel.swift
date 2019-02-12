//
//  InfoModel.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/13/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

class InfoModel: FirebaseModel {
  
  static var keyPath: String {
    return Keys.info
  }
  
  static var notification: Notification.Name? {
    return .receiveInfo
  }
  
  var id: String!
  var infoTitle: String!
  var html: String!
  var type: InfoType!
  
  required init?(dictionary: SnapshotDictionary, key: String) {
    guard let dict = dictionary,
      let title = dict[Keys.Info.infoTitle] as? String, 
      let html = dict[Keys.Info.html] as? String,
      let type = dict[Keys.Info.type] as? Int    
    else { return nil }
    self.id = key
    self.infoTitle = title
    self.html = html
    self.type = InfoType(rawValue: type)
  }
}
