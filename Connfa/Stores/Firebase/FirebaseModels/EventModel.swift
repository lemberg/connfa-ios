//
//  EventModel.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/14/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation
import EventKit

class EventModel: RelationFirebaseModel {
  
  typealias Speakers = (speakerUniqueName: String, speakerFullName: String)
  
  static var keyPath: String {
    return Keys.events
  }
  
  static var notification: Notification.Name? {
    return .receiveEvent
  }
  
  var speakersJoinedFullNames: String? {
    return speakers.count > 0 ? (speakers.map{ $0.speakerFullName }).joined(separator: ", ") : nil
  }
  
  func convertedToCalendarEvent(eventStore: EKEventStore) -> EKEvent {
    let event = EKEvent(eventStore: eventStore)
    event.title = name
    event.startDate = fromDate
    event.endDate = toDate    
    return event
  }
  
  var id: String!
  var uniqueName: String!
  var name: String!
  var from: String!
  var to: String!
  var text: String?
  var place: String?
  var experienceLevel: Int!
  var type: String?
  var track: String?
  var link: String?
  var fromDate: Date!
  var toDate: Date!
  var isSelectable: Bool
  var speakers: [Speakers] = []
  
  required init?(dictionary: SnapshotDictionary, key: String) {
    let formatter = defaultFormatter
    guard let dict = dictionary,
      let from = dict[Keys.Event.from] as? String,
      let to = dict[Keys.Event.to] as? String,
      let fromDate = formatter.date(from: from),
      let toDate = formatter.date(from: to),
      let name = dict[Keys.Event.name] as? String,
      let uniqueName = dict[Keys.uniqueName] as? String
    else { return nil }
    self.id = key
    self.from = from
    self.to = to
    self.fromDate = fromDate
    self.toDate = toDate
    self.name = name
    self.uniqueName = uniqueName
    self.experienceLevel = dict[Keys.Event.experienceLevel] as? Int ?? -1
    self.text = dict[Keys.Event.text] as? String
    self.place = dict[Keys.Event.place] as? String
    self.type = dict[Keys.Event.type] as? String
    self.track = dict[Keys.Event.track] as? String
    self.link = dict[Keys.Event.link] as? String
    self.isSelectable = dict[Keys.Event.isSelectable] as? Bool ?? true
    
    if let speakersArray = dict[Keys.speakers] as? NSArray {
      for speakerItem in speakersArray {
        if let speakerDict = speakerItem as? [String: Any], let uniqueName = speakerDict[Keys.uniqueName] as? String, let firstName = speakerDict[Keys.Speaker.firstName] as? String, let lastName = speakerDict[Keys.Speaker.lastName] as? String {
          speakers.append((speakerUniqueName: uniqueName, speakerFullName: "\(firstName) \(lastName)"))
        }
      }
    }
  }
}
