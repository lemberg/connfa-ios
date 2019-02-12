//
//  SpeakerFirebaseModel.swift
//  ConnfaTests
//
//  Created by Roman Malinovskyi on 1/5/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest

@testable import Connfa

class SpeakerFirebaseModelTests: XCTestCase {
  
  var speakerInListObject: SpeakerInList!
  var speakerDetailsObject: SpeakerDetail!
  
  override func setUp() {
    super.setUp()
    
    let keyInList = "0"

    let dataInList:[String: Any]? = [Keys.uniqueName : "test",
                                     Keys.Speaker.avatarImageURL : "http://placehold.it/120x120&text=image1",
                                     Keys.Speaker.organizationName : "test",
                                     Keys.Speaker.jobTitle : "test",
                                     Keys.Speaker.firstName : "test",
                                     Keys.Speaker.lastName : "test",]
    
    speakerInListObject = SpeakerInList(dictionary: dataInList, key: keyInList)
    speakerDetailsObject = SpeakerDetail(dictionary: dataInList, key: keyInList)
    print(speakerDetailsObject)
  }
  
  func testInitReturnNotNil() {
    XCTAssertNotNil(speakerInListObject, "Object has got failable initializer")
    XCTAssertNotNil(speakerDetailsObject, "Object has got failable initializer")
  }

  func testNameHeaderValues() {
    let header = String(speakerInListObject.firstName[speakerInListObject.firstName.startIndex]).uppercased()
    let result = speakerInListObject.nameHeader == header
    
    XCTAssertTrue(result, "nameHeader doesn't work correctly")
  }
  
  func testFullNameValues() {
    let fullName = speakerInListObject.firstName + " " + speakerInListObject.lastName
    let result = speakerInListObject.fullName == fullName
    
    XCTAssertTrue(result, "fullName doesn't work correctly")
  }
  
  func testOrganisationAndPositionValues() {
    let organisationAndPosition = [speakerInListObject.organisationName, speakerInListObject.jobTitle].flatMap{ $0 }.joined(separator: " / ")
    let result = speakerInListObject.organisationAndPosition == organisationAndPosition
    
    XCTAssertTrue(result, "organisationAndPosition doesn't work correctly")
  }
  
  func testAbbreviationValues() {
    speakerInListObject.firstName = "test"
    speakerInListObject.lastName = "test"
    
    var testString = String()
    
    if speakerInListObject.firstName.count > 0 {
      testString.append(speakerInListObject.nameHeader)
    }
    
    if speakerInListObject.lastName.count > 0 {
      testString.append(speakerInListObject.lastName[speakerInListObject.lastName.startIndex])
    }
    
    let testResult = testString == "" ? "Unknown" : testString.uppercased()
    let result = testResult == speakerInListObject.abbreviation
    
    XCTAssertTrue(result, "Abbreviation doesn't work correctly")
  }
}
