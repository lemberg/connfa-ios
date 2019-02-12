//
//  FloorPlanModel.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/13/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

class FloorPlanModel: FirebaseModel {
  
  static var keyPath: String {
    return Keys.floorPlans
  }
  
  static var notification: Notification.Name? {
    return .receiveFloorPlans
  }
  
  var id: String!
  var floorPlanName: String!
  var floorPlanImageURL: String!
  var order: Int?
  
  required init?(dictionary: SnapshotDictionary, key: String) {
    guard let dict = dictionary,
      let floorPlanName = dict[Keys.FloorPlan.floorPlanName] as? String,
      let floorPlanImageURL = dict[Keys.FloorPlan.floorPlanImageURL] as? String
    else { return nil }
    self.id = key
    self.floorPlanName = floorPlanName
    self.floorPlanImageURL = floorPlanImageURL
    self.order = dict[Keys.order] as? Int
  }
}
