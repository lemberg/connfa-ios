//
//  FloorPlanFirebaseModel.swift
//  ConnfaTests
//
//  Created by Roman Malinovskyi on 1/5/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest

@testable import Connfa

class FloorPlanFirebaseModelTests: XCTestCase {
  
  var floorPlanObject: FloorPlanModel!
  
  override func setUp() {
    super.setUp()
    
    let key = "0"
    let data:[String: Any]? = [Keys.FloorPlan.floorPlanName : "test",
                               Keys.FloorPlan.floorPlanImageURL : "http://placehold.it/120x120&text=image1"]
    
    floorPlanObject = FloorPlanModel(dictionary: data, key: key)
  }
  
  func testInitReturnNotNil() {
    XCTAssertNotNil(floorPlanObject, "Object has got failable initializer")
  }
  
  func testNotificationKey() {
    XCTAssertTrue(FloorPlanModel.notification == .receiveFloorPlans, "Object has got inccorect notification value")
  }
  
  func testKeyPath() {
    XCTAssertTrue(FloorPlanModel.keyPath == Keys.floorPlans, "Object has got inccorect locations value")
  }
}
