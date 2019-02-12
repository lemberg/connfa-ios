//
//  MoreTableViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/25/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class MoreTableViewController: UITableViewController {
  @IBOutlet weak var logo: UIImageView!
  @IBOutlet weak var titleMajor: UILabel!
  @IBOutlet weak var titleMinor: UILabel!
  @IBOutlet weak var headerView: UIView!
  
  private static let identifier = "moreCellIdentifier"
  
  private let titleRepository = FirebasePropertiesRepository<TitleModel>()
  private let infoRepository = FirebaseArrayRepository<InfoModel>()
  
  weak var delegate: MoreViewControllerDelegate?
  
  var infoArr: [InfoModel] = []
  
  var appTitle: TitleModel? {
    didSet {
      titleMajor.text = appTitle?.titleMajor
      titleMinor.text = appTitle?.titleMinor
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(receiveTitle), name: .receiveTitle , object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(receiveInfo), name: .receiveInfo, object: nil)
    appTitle = titleRepository.firstValue
    infoArr = infoRepository.models
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    // Dynamic sizing for the header view
    if let headerView = tableView.tableHeaderView {
      let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
      var headerFrame = headerView.frame
      
      if height != headerFrame.size.height {
        headerFrame.size.height = height
        headerView.frame = headerFrame
        tableView.tableHeaderView = headerView
      }
    }
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1 + (infoArr.isEmpty ? 0 : 1)
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return infoArr.count
    case 1:
      return 1
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch indexPath.section {
    case 0:
      let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewController.identifier) as! MoreTableViewCell
      cell.title.text = infoArr[indexPath.row].infoTitle
      cell.logo.image = infoArr[indexPath.row].type.image
      return cell
    case 1:
      let cell = tableView.dequeueReusableCell(withIdentifier: MoreTableViewController.identifier) as! MoreTableViewCell
      cell.title.text = Constants.Title.venue
      cell.logo.image = #imageLiteral(resourceName: "floor-plan-icon")
      return cell
    default:
      return UITableViewCell()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.didSelectRow(at: indexPath)
  }
  
  @objc func receiveTitle() {
    appTitle = titleRepository.firstValue
  }
  
  @objc func receiveInfo() {
    infoArr = infoRepository.models
    tableView.reloadData()
  }
}
