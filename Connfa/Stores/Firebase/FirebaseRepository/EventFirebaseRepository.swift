//
//  EventFirebaseRepository.swift
//  Connfa
//
//  Created by Marian Fedyk on 1/4/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation

class EventFirebaseRepository: FirebaseArrayRepository<EventModel> {
  
  func eventsFor(speakerUniqueName: String) -> [EventModel] {
    return models.filter{ contains(eventUniqueName: $0.uniqueName, speakerUniqueName: speakerUniqueName) }
  }
  
  func contains(eventUniqueName: String, speakerUniqueName: String) -> Bool {
    let events = models.filter{ $0.uniqueName == eventUniqueName }
    if let event = events.first {
      return event.speakers.contains{ $0.speakerUniqueName == speakerUniqueName }
    } else {
      return false
    }
  }
  
  func eventsWith(IDs: [String]) -> [EventModel] {
    return models.filter({ (event) -> Bool in
      return IDs.contains(event.id)
    })
  }
  
}
