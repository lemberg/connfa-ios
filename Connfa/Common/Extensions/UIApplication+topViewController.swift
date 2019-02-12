//
//  UIApplication+topViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/6/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

extension UIApplication {
  static func topViewController(controller: UIViewController? = shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
      return topViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return topViewController(controller: selected)
      }
    }
    if let presented = controller?.presentedViewController {
      return topViewController(controller: presented)
    }
    return controller
  }
}
