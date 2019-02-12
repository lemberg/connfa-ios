//
//  FilterStorageTests.swift
//  ConnfaTests
//
//  Created by Marian Fedyk on 10/1/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import XCTest

@testable import Connfa

class FilterStorageTests: XCTestCase {
  
  private var filter: ProgramListFilter!
  private var storageSaver: StorageDataSaver<ProgramListFilter>!
  
  override func setUp() {
    filter = ProgramListFilter()
    storageSaver = StorageDataSaver()
  }
  
  override func tearDown() {
    storageSaver.clean()
  }
  
  func filterSaveTest() {
    storageSaver.save(filter)
    XCTAssertNotNil(storageSaver.savedObject, "Storage saver doesn't work correctly")
  }
  
  func filterDeletionTest() {
    storageSaver.clean()
    XCTAssertNil(storageSaver.savedObject, "Storage saver doesn't work correctly")
  }
  
}
