//
//  UIView + hairlineImageView.swift
//  Connfa
//
//  Created by Marian Fedyk on 10/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

extension UIView {
  var hairlineImageView: UIImageView? {
    return hairlineImageView(in: self)
  }
  
  private func hairlineImageView(in view: UIView) -> UIImageView? {
    if let imageView = view as? UIImageView, imageView.bounds.height <= 1.0 {
      return imageView
    }
    for subview in view.subviews {
      if let imageView = self.hairlineImageView(in: subview) { return imageView }
    }    
    return nil
  }
}
