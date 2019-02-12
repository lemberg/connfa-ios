//
//  FloorPlanViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 7/21/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit

class FloorPlanViewController: UIViewController {
 
  // MARK: - Private properties
  @IBOutlet private weak var floorPlansCollectionView: UICollectionView!
  @IBOutlet private weak var pageControl: FloorPlanPageControl!
  @IBOutlet private weak var descriptionLabel: UILabel!
  
  private var repository = FirebaseArrayRepository<FloorPlanModel>()
  private var floors: [FloorPlanModel] = []
  private var flowLayout = UICollectionViewFlowLayout()
  
  private lazy var bottomBorder: UIView = {
    let bottomBorder = UIView()
    bottomBorder.backgroundColor = UIColor.bottomBackgroundColor
    bottomBorder.translatesAutoresizingMaskIntoConstraints = false
    return bottomBorder
  }()
  
  private lazy var emptyFloorsView: UIView = {
    let emptyView = EmptyStateView.instanceFromNib().forEmptyScreen(.floorPlan)
    emptyView.frame = view.frame
    return emptyView
  }()
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: .receiveFloorPlans, object: nil)
    floors = repository.values
    self.updateUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.delegate = self    
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.delegate = nil
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    if flowLayout.itemSize != floorPlansCollectionView.frame.size {
      flowLayout.itemSize = floorPlansCollectionView.frame.size
    }
  }
  
  // MARK: - Actions
  @objc func updateUI() {
    floors = repository.values
    if floors.isEmpty {
      setEmptyUI()
    } else {
      setUI()
    }
  }
  
  // MARK: - Private functions
  private func floorPlan(for indexPath: IndexPath) -> FloorPlanModel {
    return floors[indexPath.item]
  }
  
  private func floorPlan(for pageNamber: Int) -> FloorPlanModel {
    return floors[pageNamber]
  }
  
  private func setEmptyUI() {
    floorPlansCollectionView.isHidden = true
    view.addSubview(emptyFloorsView)
    descriptionLabel.text = ""
    pageControl.numberOfPages = 0
  }
  
  private func setUI() {
    pageControl.numberOfPages = floors.count
    floorPlansCollectionView.isHidden = false
    if view.subviews.contains(emptyFloorsView) {
      emptyFloorsView.removeFromSuperview()
    }
    floorPlansCollectionView?.dataSource = self
    floorPlansCollectionView?.delegate = self
    
    let cellSize = floorPlansCollectionView.frame.size
    flowLayout.scrollDirection = .horizontal
    flowLayout.itemSize = cellSize
    flowLayout.minimumLineSpacing = 0
    flowLayout.minimumInteritemSpacing = 0
    floorPlansCollectionView.setCollectionViewLayout(flowLayout, animated: true)
    floorPlansCollectionView?.reloadData()
    descriptionLabel.text = floorPlan(for: 0).floorPlanName
    pageControl.customizeDots(onPage: 0)
  }
}

extension FloorPlanViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return floors.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlanCell", for: indexPath) as! FloorPlanCollectionViewCell
    cell.fill(with: floorPlan(for: indexPath))
    return cell
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let pageNumber = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    pageControl.currentPage = pageNumber
    descriptionLabel.text = floorPlan(for: pageNumber).floorPlanName
    pageControl.customizeDots(onPage: pageNumber)
  }
  
  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let cell = cell as! FloorPlanCollectionViewCell
    cell.zoomOut()
  }
}

extension FloorPlanViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {    
    navigationController?.popToRootViewController(animated: false)
  }
}
