//
//  SocialMediaParentViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 10/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class SocialMediaParentViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.titleView = NavigationTitleLabel(withText: "Social Media")
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.shadowImage = UIImage()
  }
}
