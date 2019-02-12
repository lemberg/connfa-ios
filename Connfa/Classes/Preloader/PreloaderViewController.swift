//
//  PreloaderViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 6/22/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

class PreloaderViewController: UIViewController {
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(self.performLoggedFlow), name: .signedIn , object: nil)
    activityIndicator.startAnimating()
    UserFirebase.shared.signIn()
  }
  
  @objc private func performLoggedFlow() {
    guard let window = UIApplication.shared.keyWindow else { return }
    guard let rootViewController = window.rootViewController else { return }
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewController(withIdentifier: Constants.StoryboardID.mainTabBarController)
    vc.view.frame = rootViewController.view.frame
    vc.view.layoutIfNeeded()
    UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
      window.rootViewController = vc
    }, completion: { completed in
      NotificationCenter.default.removeObserver(self)
      NotificationCenter.default.post(name: .dismissedPreloader, object: nil, userInfo: nil)
    })
  }
  
}
