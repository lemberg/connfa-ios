//
//  InfoViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/13/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {
  
  //MARK: - Public properties
  var infoModel: InfoModel!
  
  //MARK: - Private properties
  private var childController: WebViewController?
  private var viewData: WebViewData!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    viewData = WebViewData(content: infoModel.html, style: .default)
    updateWeb()
    addShadowToNavigationBar()
    navigationItem.title = infoModel.infoTitle
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.delegate = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.delegate = nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    let destination = segue.destination as! WebViewController
    destination.viewData = viewData
    childController = destination
  }
  
  private func updateWeb() {
    childController?.viewData = viewData
    childController?.reloadContent()
  }
}

extension InfoViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    navigationController?.popToRootViewController(animated: false)
  }
}
