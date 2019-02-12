//
//  UIActivityViewController+default.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/4/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

extension UIActivityViewController {
  func withDefaultExcludedActivity() -> UIActivityViewController {
    self.excludedActivityTypes = [
      UIActivity.ActivityType.postToWeibo,
      UIActivity.ActivityType.print,
      UIActivity.ActivityType.assignToContact,
      UIActivity.ActivityType.saveToCameraRoll,
      UIActivity.ActivityType.addToReadingList,
      UIActivity.ActivityType.postToFlickr,
      UIActivity.ActivityType.postToVimeo,
      UIActivity.ActivityType.postToTencentWeibo
    ]
    return self
  }
}

