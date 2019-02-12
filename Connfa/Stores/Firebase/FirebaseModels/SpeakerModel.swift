//
//  SpeakerModel.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

public class SpeakerInList: RelationFirebaseModel {
  
  static var keyPath: String {
    return Keys.speakers
  }
  
  static var notification: Notification.Name? {
    return .receiveSpeakers
  }
  
  var id: String!
  var uniqueName: String!
  var avatarUrl: String?
  var firstName: String!
  var lastName: String!
  var organisationName: String?
  var jobTitle: String?
  var characteristic: String?
  var eventsUniqueNames: [String] = []
  
  var nameHeader: String {
    return String(firstName[firstName.startIndex]).uppercased()
  }
  
  var fullName: String {
    return firstName + " " + lastName
  }
  
  var abbreviation: String {
    var result: String = String()
    if firstName.count > 0 {
      result.append(nameHeader)
    }
    if lastName.count > 0 {
      result.append(lastName[lastName.startIndex])
    }
    return result == "" ? "Unknown" : result.uppercased()
  }
  
  var organisationAndPosition: String {
    return [organisationName, jobTitle].compactMap{ $0 }.joined(separator: " / ")
  }
  
  required public init?(dictionary: SnapshotDictionary, key: String) {
    guard let dict = dictionary,
      let uniqueName = dict[Keys.uniqueName] as? String,
      let firstName = dict[Keys.Speaker.firstName] as? String,
      let lastName = dict[Keys.Speaker.lastName] as? String
      else { return nil }
      self.id = key
      self.uniqueName = uniqueName
      self.firstName = firstName
      self.lastName = lastName
      self.characteristic = dict[Keys.Speaker.characteristic] as? String
      self.avatarUrl = dict[Keys.Speaker.avatarImageURL] as? String
      self.organisationName = dict[Keys.Speaker.organizationName] as? String
      self.jobTitle = dict[Keys.Speaker.jobTitle] as? String
      self.eventsUniqueNames = dict[Keys.events] as? [String] ?? []
  }
}

public class SpeakerDetail: SpeakerInList {
  var twitterName: String?
  var webSite: String?
  var email: String?
  
  required public init?(dictionary: SnapshotDictionary, key: String) {
    super.init(dictionary: dictionary, key: key)
    guard let dict = dictionary else { return nil }
    self.twitterName = dict[Keys.Speaker.twitterName] as? String
    self.webSite = dict[Keys.Speaker.webSite] as? String
    self.email = dict[Keys.Speaker.email] as? String
  }
}


