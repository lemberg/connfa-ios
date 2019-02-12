//
//  LocationFirebaseModel.swift
//  ConnfaTests
//
//  Created by Roman Malinovskyi on 1/5/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest
import MapKit

@testable import Connfa

class LocationFirebaseModelTests: XCTestCase {
  
  var locationObject: LocationModel!
  
  override func setUp() {
    super.setUp()

    let key = "0"
    
    let data:[String: Any]? = [Keys.Location.address : "test",
                               Keys.Location.latitude : Double(0.0),
                               Keys.Location.longitude : Double(0.0),
                               Keys.Location.locationName : "test",
                               Keys.Location.image : "http://placehold.it/120x120&text=image1"]
    
    locationObject = LocationModel(dictionary: data, key: key)
  }
  
  func testInitReturnNotNil() {
    XCTAssertNotNil(locationObject, "Object has got failable initializer")
  }
  
  func testNotificationKey() {
    XCTAssertTrue(LocationModel.notification == .receiveLocations, "Object has got inccorect notification value")
  }
  
  func testkeyPath() {
    XCTAssertTrue(LocationModel.keyPath == Keys.locations, "Object has got inccorect locations value")
  }
  
  func testCLLocationMethod() {
    let location = CLLocation(latitude: locationObject.latitude, longitude: locationObject.longitude)
    XCTAssertTrue((location.coordinate.longitude == locationObject.clLocation.coordinate.longitude) &&
      (location.coordinate.latitude == locationObject.clLocation.coordinate.latitude)
      , "clLocation doesn't work correctly")
  }
  
  func testCLLocation2DMethod() {
    let location = CLLocationCoordinate2D(latitude: locationObject.latitude, longitude: locationObject.longitude)
    XCTAssertTrue((location.longitude == locationObject.clLocationCoordinate2D.longitude) &&
      (location.latitude == locationObject.clLocationCoordinate2D.latitude)
      , "clLocationCoordinate2D doesn't work correctly")
  }
  
  func testStreetAndNumberMethod() {
    locationObject.address = "test, test, test"
    
    let address = locationObject.address.components(separatedBy: ",").first
    let result = locationObject.streetAndNumber == address
    
    XCTAssertTrue(result, "streetAndNumber doesn't work correctly")
    
    locationObject.address = ""
    
    XCTAssertTrue(locationObject.streetAndNumber == "", "streetAndNumber doesn't work correctly")
  }

  func testCityAndProvinceMethod() {
    locationObject.address = "test, test, test"
    let components = locationObject.address.components(separatedBy: ",")
    let result = locationObject.cityAndProvince == components[1]

    XCTAssertTrue(result, "cityAndProvince doesn't work correctly")
    
    locationObject.address = ""
    
    XCTAssertTrue(locationObject.cityAndProvince == "", "cityAndProvince doesn't work correctly")
  }
  
  func testStateMethod() {
    locationObject.address = "test, test, test"
    
    let components = locationObject.address.components(separatedBy: ",")
    let result = locationObject.state == components[2]

    XCTAssertTrue(result, "state doesn't work correctly")
    
    locationObject.address = ""
    
    XCTAssertTrue(locationObject.state == "", "state doesn't work correctly")
  }
}
