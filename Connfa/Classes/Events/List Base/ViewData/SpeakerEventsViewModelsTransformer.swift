//
//  SpeakerEventsViewModelsTransformer.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/24/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation
import SwiftDate

class SpeakerEventsViewModelsTransformer {
  static var `default`: SpeakerEventsViewModelsTransformer {
    var slotFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone(identifier: Configurations().timeZoneIdentifier)
      formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.autoupdatingCurrent)
      return formatter
    }
    var shortFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone(identifier: Configurations().timeZoneIdentifier)
      formatter.dateFormat = "E, MMMM d"
      return formatter
    }
    return SpeakerEventsViewModelsTransformer(slot: slotFormatter, short: shortFormatter)
  }
  
  private var shortDateFormatter: DateFormatter
  private var slotFormatter: DateFormatter
  
  init(slot: DateFormatter, short: DateFormatter) {
    shortDateFormatter = short
    slotFormatter = slot
  }
  
  public func transform(_ events: [EventModel]) -> DayList {
    var tmpList: DayList = [:]
    events.forEach { (event) in
      let slot = ProgramListSlotViewData(start: self.slotFormatter.string(from: event.fromDate), end: self.slotFormatter.string(from: event.toDate), marker: marker(forStart: event.fromDate))
      let levelImageName = event.experienceLevel >= 0 ? ExperienceLevel(rawValue: event.experienceLevel)!.imageName : nil
      let speakers = event.speakersJoinedFullNames
      let item = ProgramListViewData(eventId: event.id, name: event.name, isSelectable: event.isSelectable, place: event.place, levelImageName: levelImageName, type: event.type, speakers: speakers, track: event.track)
      tmpList[slot] = [item]
    }
    return tmpList
  }
  
  private func marker(forStart start: Date) -> ProgramListSlotViewData.Marker {
    return .dateString(shortDateFormatter.string(from: start))
  }
}
