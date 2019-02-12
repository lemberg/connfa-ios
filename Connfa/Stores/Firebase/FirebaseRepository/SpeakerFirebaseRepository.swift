//
//  SpeakerFirebaseRepository.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/19/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

class SpeakerFirebaseRepository: FirebaseArrayRepository<SpeakerInList> {  
  public func speakersFrom(eventUniqueName: String) -> [SpeakerInList] {
    return models.filter{ $0.eventsUniqueNames.contains(eventUniqueName) }
  }
}

class SpeakerDetailFirebaseRepository: FirebaseArrayRepository<SpeakerDetail> {
  public func speakerBy(uniqueName: String) -> SpeakerDetail? {
    return models.filter{ $0.uniqueName == uniqueName }.first
  }
}

