//
//  EventStorageTests.swift
//  ConnfaTests
//
//  Created by Marian Fedyk on 10/2/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest
import EventKit

@testable import Connfa

/// EventKit will work on device only. Also don't forgot to give a permission to access your calendar before testing.
class EventStorageTests: XCTestCase {
  
  private var eventStorage: EventStorage!
  private var eventModel: EventModel?
  private var eventStore: EKEventStore!
  
  override func setUp() {
    super.setUp()
    eventStore = EKEventStore()
    eventStorage = EventStorage(store: eventStore)
    let key = "0"
    let data: SnapshotDictionary = [
      Keys.Event.from : "2018-06-18T11:08:00+0300",
      Keys.Event.to : "2018-06-18T12:17:40+0300",
      Keys.Event.name : "Coffee",
      Keys.uniqueName : "626"
    ]
    eventModel = EventModel(dictionary: data, key: key)
  }
  
  func testCalendarEventCreation() {
    guard let event = eventModel else {
      XCTFail("Object has got failable initializer")
      return
    }
    eventStorage.addToCalendar(events: [event])
    let predicate = eventStore.predicateForEvents(withStart: event.fromDate, end: event.toDate, calendars: nil)
    let ekEvents = eventStore.events(matching: predicate)
    XCTAssertTrue(!ekEvents.isEmpty, "Event storage creation does not work properly")
  }
  
  func testCalendarEventRemoval() {
    guard let event = eventModel else {
      XCTFail("Object has got failable initializer")
      return
    }
    let predicate = eventStore.predicateForEvents(withStart: event.fromDate, end: event.toDate, calendars: nil)
    
    var ekEvents = eventStore.events(matching: predicate)
    XCTAssertTrue(!ekEvents.isEmpty, "Event storage creation does not work properly")
    eventStorage.removefromCalendar(events: [event])
    ekEvents = eventStore.events(matching: predicate)
    XCTAssertTrue(ekEvents.isEmpty, "Event storage deletion does not work properly")
  }
}
