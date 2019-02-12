//
//  Keys.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

struct Keys {
  
  struct Location {
    static let locationId = "locationId"
    static let locationName = "locationName"
    static let longitude = "longitude"
    static let latitude = "latitude"
    static let address = "address"
    static let image = "image"
  }
  
  struct Speaker {
    static let speakerId = "speakerId"
    static let firstName = "firstName"
    static let lastName = "lastName"
    static let avatarImageURL = "avatarImageURL"
    static let jobTitle = "jobTitle"
    static let webSite = "webSite"
    static let characteristic = "characteristic"
    static let email = "email"
    static let organizationName = "organizationName"
    static let twitterName = "twitterName"
  }
  
  struct FloorPlan {
    static let floorPlanId = "floorPlanId"
    static let floorPlanName = "floorPlanName"
    static let floorPlanImageURL = "floorPlanImageURL"
  }
  
  struct POI {
    static let poiId = "poiId"
    static let poiName = "poiName"
    static let poiDescription = "poiDescription"
    static let poiImageURL = "poiImageURL"
    static let poiDetailURL = "poiDetailURL"
  }
  
  struct Info {
    static let infoId = "infoId"
    static let infoTitle = "infoTitle"
    static let html = "html"
    static let type = "type"
  }
  
  struct Event {
    static let eventId = "eventId"
    static let name = "name"
    static let text = "text"
    static let place = "place"
    static let experienceLevel = "experienceLevel"
    static let type = "type"
    static let from = "from"
    static let to = "to"
    static let track = "track"
    static let link = "link"
    static let isSelectable = "isSelectable"
  }
  
  struct Schedule {
    static let code = "code"
    static let id = "id"
  }
  
  struct User {
    static let ownPin = "ownPin"
    static let pinId = "pinId"
  }
  
  struct Title {
    static let titleMajor = "titleMajor"
    static let titleMinor = "titleMinor"
  }
  
  static let sponsors = "sponsors"
  static let uniqueName = "uniqueName"
  static let schedules = "schedules"
  static let events = "events"
  static let info = "info"
  static let poi = "poi"
  static let floorPlans = "floorPlans"
  static let locations = "locations"
  static let speakers = "speakers"
  static let order = "order"
  static let deleted = "deleted"
  static let users = "users"
  static let pins = "pins"
  static let interested = "interested"
  static let displayName = "displayName"
  static let title = "title"
  static var startDate: String {
    return Configurations().startDate
  }
}
