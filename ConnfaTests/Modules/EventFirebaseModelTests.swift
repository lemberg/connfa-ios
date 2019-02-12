//
//  EventFirebaseModel.swift
//  ConnfaTests
//
//  Created by Roman Malinovskyi on 1/5/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest

@testable import Connfa

class EventFirebaseModelTests: XCTestCase {
  
  var eventObject: EventModel!
  
  override func setUp() {
    super.setUp()
    
    let key = "0"
    let data:[String: Any]? = [Keys.Event.from : "2017-12-03T15:00:00+0200",
                               Keys.Event.to : "2017-12-03T16:00:00+0200",
                               Keys.Event.name : "name",
                               Keys.uniqueName : "test",
                               Keys.Event.experienceLevel : Int(1),
                               Keys.Event.text : "test",
                               Keys.Event.place : "test",
                               Keys.Event.type : "test",
                               Keys.Event.track : "Some Track 1",
                               Keys.Event.link : "test",
                               Keys.speakers : NSArray()
                               ]

    eventObject = EventModel(dictionary: data, key: key)
  }
  
  func testInitReturnNotNil() {
    XCTAssertNotNil(eventObject, "Object has got failable initializer")
  }
}
