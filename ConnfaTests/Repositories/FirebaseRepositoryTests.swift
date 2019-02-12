//
//  FirebaseRepository.swift
//  ConnfaTests
//
//  Created by Roman Malinovskyi on 1/5/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest

@testable import Connfa

class FirebaseRepositoryTests: XCTestCase {
  
  var speakerRepository: SpeakerFirebaseRepository!
  var infoRepository: FirebaseArrayRepository<InfoModel>!
  
  var expectation: XCTestExpectation!
  
  func receivedSpeakers() {    
    guard !speakerRepository.values.isEmpty else {
      XCTAssertTrue(false, "No values were received")
      return
    }
    
    let randomID = Int(arc4random_uniform(UInt32(speakerRepository.values.count)))
    let randomModel = speakerRepository.values[randomID]
    let valueById = speakerRepository.valueBy(id: randomModel.id)
    
    XCTAssertTrue(valueById?.id == randomModel.id, "valueBy doesn't work correctly")
    
    expectation.fulfill()
  }
  
  func receivedInfo() {
    XCTAssertTrue(infoRepository.values.count != 0, "No values were received")
        
    let randomID = Int(arc4random_uniform(UInt32(infoRepository.values.count)))
    let randomModel = infoRepository.values[randomID]
    let valueById = infoRepository.valueBy(id: randomModel.id)
    
    XCTAssertTrue(valueById?.id == randomModel.id, "valueBy doesn't work correctly")
    
    expectation.fulfill()
  }
  
  func testSpeakersRepository() {
    speakerRepository = SpeakerFirebaseRepository()
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.receivedSpeakers), name: .receiveSpeakers, object: nil)
    expectation = XCTestExpectation(description: "Receive values from response")
    let values = speakerRepository.values
    XCTAssertTrue(values.count == 0, "Repository return not empty array of objects after first cold invocation")
    
    wait(for: [expectation], timeout: 10.0)
  }
  
  func testInfoRepository() {
    infoRepository = FirebaseArrayRepository<InfoModel>()
    
    NotificationCenter.default.addObserver(self, selector: #selector(self.receivedInfo), name: .receiveInfo, object: nil)
    expectation = XCTestExpectation(description: "Receive values from response")
    let values = infoRepository.values
    XCTAssertTrue(values.count == 0, "Repository return not empty array of objects after first cold invocation")
    
    wait(for: [expectation], timeout: 10.0)
  }
}
