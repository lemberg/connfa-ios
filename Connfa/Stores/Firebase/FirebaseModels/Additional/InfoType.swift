//
//  InfoType.swift
//  Connfa
//
//  Created by Marian Fedyk on 2/13/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

public enum InfoType: Int {
  case aboutApp = 0
  case aboutEvent
  case sponsors
  
  var image: UIImage {
    switch self {
    case .aboutApp:
      return #imageLiteral(resourceName: "connfa-icon")
    case .aboutEvent:
      return #imageLiteral(resourceName: "drupal-icon")
    case .sponsors:
      return #imageLiteral(resourceName: "sponsor-icon")
    }
  }
}
