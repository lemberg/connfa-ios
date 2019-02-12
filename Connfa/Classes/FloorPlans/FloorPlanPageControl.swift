//
//  FloorPlanPageControl.swift
//  Connfa
//
//  Created by Marian Fedyk on 10/2/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class FloorPlanPageControl: UIPageControl {
  func customizeDots(onPage: Int) {
    for dot in self.subviews {
      if let i = self.subviews.index(of: dot) , i != onPage {
        dot.layer.borderWidth = 1.0
        dot.layer.borderColor = UIColor.lightGray.cgColor
        dot.backgroundColor = UIColor.clear
      } else {
        dot.layer.borderWidth = 0
      }
    }
  }  
}
