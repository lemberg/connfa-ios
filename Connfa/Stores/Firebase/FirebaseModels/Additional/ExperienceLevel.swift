//
//  ExperienceLevel.swift
//  ConnfaCore
//
//  Created by Volodymyr Hyrka on 11/24/17.
//  Copyright © 2017 Lemberg Solutions. All rights reserved.
//

import Foundation

public enum ExperienceLevel: Int {
  case Beginner = 0
  case Intermediate
  case Advanced
  
  public var imageName: String {
    return "ic-level-\(self.rawValue)"
  }
  
  public var description: String {
    return String(describing: self)
  }
}
