//
//  PinModel.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/27/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation
import Firebase

class Pin: Equatable {
  var pinId: String
  var displayName: String?
  
  var actionTitle: String {
    return ("\(displayName ?? "") (\(pinId))")
  }
  
  static func ==(lhs: Pin, rhs: Pin) -> Bool {
    return lhs.pinId == rhs.pinId
  }
  
  init(dictionary: SnapshotDictionary, key: String) {
    self.pinId = key
    self.displayName = dictionary?[Keys.displayName] as? String
  }
  
  init(pinId: String, displayName: String? = nil) {
    self.pinId = pinId
    self.displayName = displayName
  }
}
