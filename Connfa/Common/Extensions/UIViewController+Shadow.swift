//
//  UIViewController+Shadow.swift
//  Connfa
//
//  Created by Marian Fedyk on 10/2/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

extension UIViewController {
  private var shadowView: UIView {
    let shadowView = UIView(frame: navigationController?.navigationBar.frame ?? CGRect.zero)
    shadowView.backgroundColor = UIColor.white
    shadowView.layer.masksToBounds = false
    shadowView.layer.applyConnfaShadow()
    return shadowView
  }
  
  func addShadowToNavigationBar() {
    navigationController?.navigationBar.isTranslucent = true    
    navigationController?.navigationBar.hideBottomHairline()
    navigationController?.navigationBar.shadowImage = UIImage()
    view.addSubview(shadowView)
  }
}
