//
//  UIViewController+isModal.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/10/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

extension UIViewController {
  var isModal: Bool {
    return presentingViewController != nil ||
      navigationController?.presentingViewController?.presentedViewController === navigationController ||
      tabBarController?.presentingViewController is UITabBarController
  }
}
