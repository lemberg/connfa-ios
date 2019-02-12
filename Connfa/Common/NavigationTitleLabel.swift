//
//  NavigationTitleLabel.swift
//  Connfa
//
//  Created by Marian Fedyk on 10/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class NavigationTitleLabel: UILabel {
  override init(frame: CGRect) {
    super.init(frame: frame)
    font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    textAlignment = .center
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  convenience init (withText: String) {
    self.init()
    text = withText
    sizeToFit()
  }
}
