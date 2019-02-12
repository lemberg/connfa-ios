//
//  UIColor+hex.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/12/17.
//

import UIKit

extension UIColor {
  convenience init(hexString : String)
  {
    if let rgbValue = UInt(hexString, radix: 16) {
      let red   =  CGFloat((rgbValue >> 16) & 0xff) / 255
      let green =  CGFloat((rgbValue >>  8) & 0xff) / 255
      let blue  =  CGFloat((rgbValue      ) & 0xff) / 255
      self.init(red: red, green: green, blue: blue, alpha: 1.0)
    } else {
      self.init(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    }
  }
  
  static var bottomBackgroundColor: UIColor {
    return UIColor(red: 200.0/255.0, green: 201.0/255.0, blue: 200.0/255.0, alpha: 1.0)
  }
}
