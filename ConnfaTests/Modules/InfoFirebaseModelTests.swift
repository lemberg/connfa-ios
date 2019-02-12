//
//  InfoFirebaseModel.swift
//  ConnfaTests
//
//  Created by Roman Malinovskyi on 1/5/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest

@testable import Connfa

class InfoFirebaseModelTests: XCTestCase {
  
  var infoObject: InfoModel!
  
  override func setUp() {
    super.setUp()
    
    let key = "0"
    let data:[String: Any]? = [Keys.Info.infoTitle : "test",
                               Keys.Info.html : "test",
                               Keys.Info.type : 0]
    
    infoObject = InfoModel(dictionary: data, key: key)
  }
  
  func testInitReturnNotNil() {
    XCTAssertNotNil(infoObject, "Object has got failable initializer")
  }
  
  func testNotificationKey() {
    XCTAssertTrue(InfoModel.notification == .receiveInfo, "Object has got inccorect notification value")
  }
  
  func testKeyPath() {
    XCTAssertTrue(InfoModel.keyPath == Keys.info, "Object has got inccorect locations value")
  }
}
