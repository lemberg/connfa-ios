//
//  EventStorage.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/12/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation
import EventKit

/// Wrapper to work with EventKit.
class EventStorage {
  private let eventStore: EKEventStore
  private let eventRepository: EventFirebaseRepository
  
  typealias AuthorizationBlock = (_ success : Bool) -> ()
  typealias ExecutionBlock = () -> ()
  
  private var isAuthorized: Bool {
    return EKEventStore.authorizationStatus(for: .event) == .authorized
  }
  
  private var calendar: EKCalendar? {
    if let identifier = UserDefaults.standard.eventCalendarIdentifier, let calendar = eventStore.calendar(withIdentifier: identifier) {
      return calendar
    } else {
      if let name = Configurations().calendarName, let source = eventStore.sources.first(where: { $0.sourceType == .calDAV || $0.sourceType == .local }) {
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = name
        newCalendar.source = source
        do {
          try eventStore.saveCalendar(newCalendar, commit: true)
        } catch let e {
          print(e)
          return nil
        }
        UserDefaults.standard.eventCalendarIdentifier = newCalendar.calendarIdentifier
        return newCalendar
      } else {
        return nil
      }
    }
  }
  
  init(store: EKEventStore = EKEventStore()) {
    eventRepository = EventFirebaseRepository()
    eventStore = store
  }
  
  //MARK: - IDs
  
  func addToCalendarEvents(ids: [String]) {
    guard isAuthorized else {
      authorize(executeAfterBlock: { self.addToCalendarEvents(ids: ids) })
      return
    }
    let events = eventRepository.eventsWith(IDs: ids)
    addToCalendar(events: events)
  }
  
  func removeFromCalendarEvents(ids: [String]) {
    guard isAuthorized else {
      authorize(executeAfterBlock: { self.removeFromCalendarEvents(ids: ids) })
      return
    }
    let events = eventRepository.eventsWith(IDs: ids)
    removefromCalendar(events: events)
  }
  
  //MARK: - EventModels
  
  func addToCalendar(events: [EventModel]) {
    guard isAuthorized else {
      authorize(executeAfterBlock: { self.addToCalendar(events: events) })
      return
    }
    events.forEach { (event) in
      addToCalendar(event)
    }
    commit()
  }
  
  func removefromCalendar(events: [EventModel]) {
    guard isAuthorized else {
      authorize(executeAfterBlock: { self.removefromCalendar(events: events) })
      return
    }
    events.forEach { (event) in
      removeFromCalendar(event: event)
    }
    commit()
  }
  
  //MARK: - Private
  
  private func commit() {
    do {
      try eventStore.commit()
    } catch let e {
      print(e)
    }
  }
  
  private func authorize(executeAfterBlock: ExecutionBlock? = nil) {
    eventStore.requestAccess(to: .event, completion: { (granted, error) in
      if granted {
        DispatchQueue.main.async {
          executeAfterBlock?()
        }
      }
    })
  }
  
  private func addToCalendar(_ event: EventModel) {
    guard let aCalendar = calendar else {
      print("Calendar not available")
      return
    }
    do {
      let calendarEvent = event.convertedToCalendarEvent(eventStore: self.eventStore)
      calendarEvent.calendar = aCalendar
      calendarEvent.alarms = [EKAlarm(relativeOffset: -5 * 60)]
      try self.eventStore.save(calendarEvent, span: .thisEvent, commit: false)
    } catch let e {
      print(e)
    }
  }
  
  private func removeFromCalendar(event: EventModel) {
    guard let aCalendar = calendar else {
      print("Calendar not available")
      return
    }
    let predicate = eventStore.predicateForEvents(withStart: event.fromDate, end: event.toDate, calendars: [aCalendar])
    let ekEvents = eventStore.events(matching: predicate)
    ekEvents.forEach { (anEvent) in
      removeFromCalendar(ekEvent: anEvent)
    }
  }
  
  private func removeFromCalendar(ekEvent: EKEvent) {
    do {
      try self.eventStore.remove(ekEvent, span: .thisEvent, commit: false)
    } catch let e {
      print(e)
    }
  }
}
