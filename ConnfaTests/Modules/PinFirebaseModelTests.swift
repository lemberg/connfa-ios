//
//  PinFirebaseModel.swift
//  ConnfaTests
//
//  Created by Roman Malinovskyi on 1/15/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest

@testable import Connfa

class PinFirebaseModelTests: XCTestCase {
  
  var pinObject: Pin!

  override func setUp() {
    super.setUp()
    
    pinObject = Pin(pinId: "0", displayName: "test")
  }  
  
  func testInitReturnNotNil() {
    XCTAssertNotNil(pinObject, "Object has got failable initializer")
  }
  
  func testEquitable() {
    let obj1 = Pin(pinId: "1")
    let obj2 = Pin(pinId: "2")
    
    var result = obj1 == obj2
    
    XCTAssertTrue(result == false, "Equitable doesn't work correctly")
    
    obj2.pinId = "1"
    result = obj1 == obj2
    
    XCTAssertTrue(result == true, "Equitable doesn't work correctly")
  }
  
  func testActionTitle() {
    let result = ("\(pinObject.displayName ?? "") (\(pinObject.pinId))") == pinObject.actionTitle
    XCTAssertTrue(result, "ActionTitle doesn't work correctly")
  }
}
