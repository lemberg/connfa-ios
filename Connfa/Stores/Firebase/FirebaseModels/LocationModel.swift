//
//  LocationModel.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/13/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation
import MapKit

class LocationModel: FirebaseModel {
  
  static var keyPath: String {
    return Keys.locations
  }
  
  static var notification: Notification.Name? {
    return .receiveLocations
  }
  
  var id: String!
  var address: String!
  var name: String!
  var imageUrl: String?
  var latitude: Double!
  var longitude: Double!
  
  var clLocation: CLLocation {
    return CLLocation(latitude: latitude, longitude: longitude)
  }
  var clLocationCoordinate2D: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
  var streetAndNumber: String {
    let components = address.components(separatedBy: ",")
    return components.first ?? ""
  }
  var cityAndProvince: String {
    let components = address.components(separatedBy: ",")
    return components.count > 1 ? components[1] : ""
  }
  var state: String {
    let components = address.components(separatedBy: ",")
    return components.count > 2 ? components[2] : ""
  }
  
  required init?(dictionary: SnapshotDictionary, key: String) {
    guard let dict = dictionary,
      let address = dict[Keys.Location.address] as? String,
      let latitude = dict[Keys.Location.latitude] as? Double,
      let longitude = dict[Keys.Location.longitude] as? Double,
      let name = dict[Keys.Location.locationName] as? String
    else { return nil }
    self.id = key
    self.address = address
    self.latitude = latitude
    self.longitude = longitude
    self.name = name
    self.imageUrl = dict[Keys.Location.image] as? String
  }
}
