//
//  ConfigurationsTests.swift
//  ConnfaTests
//
//  Created by Marian Fedyk on 10/4/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest

@testable import Connfa

class ConfigurationsTests: XCTestCase {
  
  private var configuration: Configurations!
  
  override func setUp() {
    super.setUp()
    configuration = Configurations()
  }
  
  func testTwitterApiKey() {
    let key = configuration.twitterApiKey
    XCTAssertNotNil(key, "Twitter key couldn't be found")
  }
  
  func testTwitterApiSecret() {
    let secret = configuration.twitterApiSecret
    XCTAssertNotNil(secret, "Twitter secret couldn't be found")
  }
  
  func testTintColor() {
    let color = configuration.tintColor
    XCTAssertTrue(color != .black, "Tint color couldn't be found")
  }
  
}
