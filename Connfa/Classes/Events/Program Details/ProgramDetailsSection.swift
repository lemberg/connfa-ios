//
//  ProgramDetailsSection.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/19/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation

struct ProgramDetailsSection {
  enum SectionType {
    case logoSectionType
    case speakersAndWebAndTitleSectionType
    case sponsorsSectionType
    case interestedSectionType
  }
  
  var rowNumber: Int
  var type: SectionType
  
  init?(_ type: SectionType, rows: Int = 1){
    if rows <= 0 {
      return nil
    } else {
      self.rowNumber = rows
      self.type = type
    }
  }
}
