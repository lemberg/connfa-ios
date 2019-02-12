//
//  CALayer+Shadow.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/24/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

extension CALayer {
  
  func applyConnfaShadow() {
    shadowColor = UIColor.black.cgColor
    shadowOffset = CGSize(width: 0, height: 5.0)
    shadowRadius = 5
    shadowOpacity = 0.2
  }
  
}
