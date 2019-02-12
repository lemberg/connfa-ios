//
//  VenueViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/25/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class VenueViewController: UIViewController {
  
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var blurView: UIVisualEffectView!
  @IBOutlet weak var shadowImage: UIImageView!
  
  private lazy var floorPlanViewController: FloorPlanViewController = {
    let storyboard = UIStoryboard(name: "FloorPlans", bundle: Bundle.main)
    var viewController = storyboard.instantiateViewController(withIdentifier: "FloorPlanViewController") as! FloorPlanViewController
    self.add(asChildViewController: viewController)
    return viewController
  }()
  
  private lazy var locationViewController: LocationViewController = {
    let storyboard = UIStoryboard(name: "Location", bundle: Bundle.main)
    var viewController = storyboard.instantiateViewController(withIdentifier: "LocationViewController") as! LocationViewController    
    self.add(asChildViewController: viewController)
    return viewController
  }()
  
  private lazy var pathButton: UIBarButtonItem = {
    let barItem = UIBarButtonItem(image: #imageLiteral(resourceName: "path"), style: .plain, target: self, action: #selector(pathButtonTapped))
    return barItem
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupSegmentedControl()    
    navigationItem.titleView = NavigationTitleLabel(withText: Constants.Title.venue)
    tabBarController?.tabBar.isHidden = true
  }
    
  @objc func selectionDidChange(_ sender: UISegmentedControl) {
    updateView()
  }
  
  @objc func pathButtonTapped() {
    locationViewController.pathButtonTapped()
  }
  
  private func setupSegmentedControl() {
    segmentedControl.removeAllSegments()
    segmentedControl.insertSegment(withTitle: Constants.Title.floorPlan, at: 0, animated: false)
    segmentedControl.insertSegment(withTitle: Constants.Title.location, at: 1, animated: false)
    segmentedControl.addTarget(self, action: #selector(selectionDidChange(_:)), for: .valueChanged)
    segmentedControl.selectedSegmentIndex = 0
    updateView()
  }
  
  private func add(asChildViewController viewController: UIViewController) {
    addChild(viewController)
    view.addSubview(viewController.view)
    // Configure Child View
    let viewHeight = view.bounds.height - (viewController is FloorPlanViewController ? bottomView.frame.height : 0)
    viewController.view.frame = CGRect(origin: .zero, size: CGSize(width: view.bounds.width, height: viewHeight))
    viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    viewController.didMove(toParent: self)
  }
  
  private func remove(asChildViewController viewController: UIViewController) {
    viewController.willMove(toParent: nil)
    viewController.view.removeFromSuperview()
    viewController.removeFromParent()
  }
  
  private func updateView() {
    if segmentedControl.selectedSegmentIndex == 0 {
      navigationItem.rightBarButtonItem = nil
      remove(asChildViewController: locationViewController)
      add(asChildViewController: floorPlanViewController)
    } else {
      navigationItem.rightBarButtonItem = pathButton
      remove(asChildViewController: floorPlanViewController)
      add(asChildViewController: locationViewController)
      view.bringSubviewToFront(shadowImage)
    }    
    view.bringSubviewToFront(blurView)
    view.bringSubviewToFront(bottomView)
  }
}

