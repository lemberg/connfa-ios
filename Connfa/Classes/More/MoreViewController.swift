//
//  MoreViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/27/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

protocol MoreViewControllerDelegate: class {
  func didSelectRow(at indexPath: IndexPath)  
}

class MoreViewController: UIViewController {
  
  private var childVC: MoreTableViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.titleView = NavigationTitleLabel(withText: Constants.Title.more)
    configureNavBar()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let backItem = UIBarButtonItem()
    backItem.title = Constants.Title.more
    navigationItem.backBarButtonItem = backItem
    if let destination = segue.destination as? MoreTableViewController {
      destination.delegate = self
      childVC = destination
    }
    if let vc = segue.destination as? InfoViewController, let model = sender as? InfoModel {
      vc.infoModel = model
    }
  }
  
  func configureNavBar() {
    navigationController?.navigationBar.isTranslucent = true    
    navigationController?.navigationBar.shadowImage = UIImage()
  }
}

extension MoreViewController: MoreViewControllerDelegate {
  func didSelectRow(at indexPath: IndexPath) {
    if indexPath.section == 1 {
      performSegue(withIdentifier: SegueIdentifier.showMoreViewControllerVenueViewController.rawValue, sender: nil)
    } else {
      performSegue(withIdentifier: SegueIdentifier.showMoreViewControllerInfoViewController.rawValue, sender: self.childVC?.infoArr[indexPath.row])
    }
  }
}
