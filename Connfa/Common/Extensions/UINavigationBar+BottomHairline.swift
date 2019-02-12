//
//  UINavigationBar + BottomHairline.swift
//  Connfa
//
//  Created by Marian Fedyk on 10/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

extension UINavigationBar {
  func hideBottomHairline() {
    self.hairlineImageView?.isHidden = true
  }
  
  func showBottomHairline() {
    self.hairlineImageView?.isHidden = false
  }
}
