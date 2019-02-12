//
//  EventsViewModelsTransformer.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/28/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation
import SwiftDate

class EventsViewModelsTransformer {
  static var `default`: EventsViewModelsTransformer {
    var fullFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone(identifier: Configurations().timeZoneIdentifier)
      formatter.dateFormat = "EEEE - MMMM d, yyyy"
      return formatter
    }
    let confifuration = Configurations()
    var dayFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone(identifier: confifuration.timeZoneIdentifier)
      formatter.dateFormat = "d"
      return formatter
    }
    var slotFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.timeZone = TimeZone(identifier: confifuration.timeZoneIdentifier)
      formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "HH:mm", options: 0, locale: Locale.autoupdatingCurrent)
      return formatter
    }
    return EventsViewModelsTransformer(day: dayFormatter, slot: slotFormatter, full: fullFormatter)
  }
  
  private var dayFormatter: DateFormatter
  private var fullFormatter: DateFormatter
  private var slotFormatter: DateFormatter
  
  init(day: DateFormatter, slot: DateFormatter, full: DateFormatter) {
    self.dayFormatter = day
    self.fullFormatter = full
    self.slotFormatter = slot
  }
  
  public func transform(_ events: [EventModel]) -> [ProgramListDayViewData : DayList] {
    var tmpList = [ProgramListDayViewData : DayList]()
    let now = Date()
    events.forEach { (event) in
      let day = ProgramListDayViewData(event.fromDate, dayFormatter: self.dayFormatter, fullFormatter: self.fullFormatter)
      let slot = ProgramListSlotViewData(start: self.slotFormatter.string(from: event.fromDate), end: self.slotFormatter.string(from: event.toDate), marker: marker(forStart: event.fromDate, end: event.toDate, now: now))
      let levelImageName = event.experienceLevel >= 0 ? ExperienceLevel(rawValue: event.experienceLevel)!.imageName : nil
      let speakers = event.speakersJoinedFullNames
      let item = ProgramListViewData(eventId: event.id, name: event.name, isSelectable: event.isSelectable, place: event.place, levelImageName: levelImageName, type: event.type, speakers: speakers, track: event.track)
      
      if tmpList[day] == nil {
        tmpList[day] = [slot:[item]]
      } else if tmpList[day]?[slot] == nil {
        tmpList[day]![slot] = [item]
      } else {
        tmpList[day]![slot]!.append(item)
      }
    }
    var sortedList: [ProgramListDayViewData : DayList] = [:]
    tmpList.forEach { (key, value) in
      sortedList[key] = value.mapValues{ $0.sorted{ $0.name < $1.name } }
    }
    return sortedList
  }
  
  //MARK: - private
  private func marker(forStart start: Date, end: Date, now: Date) -> ProgramListSlotViewData.Marker {
    if end < now {
      return .none
    } else if start > now {
      return .upcoming
    }
    return .going
  }
}
