//
//  ProgramListFilterViewController.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/2/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

protocol ProgramListFilterDelegate: class {
  func filter(_ controller: ProgramListFilterViewController, didChange filter: ProgramListFilter)
}

class ProgramListFilterViewController: UIViewController {

  private let typeSection = 0
  private let levelSection = 1
  private let trackSection = 2
    
  weak var delegate: ProgramListFilterDelegate?
  var filter: ProgramListFilter!
  
  @IBOutlet fileprivate weak var topView: UIView!
  @IBOutlet fileprivate weak var table: UITableView!
  
  fileprivate lazy var filterAdapter: ProgramListFilterAdapter = ProgramListFilterAdapter()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configTable()
  }
 
  @IBAction func onReset() {
    filter.reset()
    delegate?.filter(self, didChange: filter)
    table.reloadData()
  }
  
  @IBAction func onDone() {
    if filter.isEmpty {
        filter.reset()
    }
    
    delegate?.filter(self, didChange: filter)
    dismiss(animated: true, completion: nil)
  }
  
  //MARK: - private
  private func configTable() {
    table.register(UINib(nibName: ProgramListFilterHeader.identifier, bundle: nil), forHeaderFooterViewReuseIdentifier: ProgramListFilterHeader.identifier)
    table.register(UINib(nibName: ProgramListFilterCell.identifier, bundle: nil), forCellReuseIdentifier: ProgramListFilterCell.identifier)
    table.estimatedRowHeight = 44
    table.rowHeight = 44
    let inset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    table.contentInset = inset    
  }
}

extension ProgramListFilterViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return 3
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == typeSection {
      return filter.types.count
    } else if section == levelSection {
      return filter.levels.count
    } else if section == trackSection {
      return filter.tracks.count
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var item: ProgramListFilter.FilterItem!
    let cell = tableView.dequeueReusableCell(withIdentifier: ProgramListFilterCell.identifier, for: indexPath) as! ProgramListFilterCell
    if indexPath.section == typeSection {
      item = filter.types[indexPath.row]
    } else if indexPath.section == levelSection {
      item = filter.levels[indexPath.row]
    } else if indexPath.section == trackSection {
      item = filter.tracks[indexPath.row]
    }
    cell.checkmark.image = checkmarkImage(marked: item.mark)
    cell.title.text = filterAdapter.adapted(item.title)
    return cell
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProgramListFilterHeader.identifier) as! ProgramListFilterHeader
    switch section {
    case typeSection:
        header.title.text = "Type"
    case levelSection:
        header.title.text = "Level"
    case trackSection:
        header.title.text = "Track"
    default:
        header.title.text = "Unknown"
    }
    return header
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == typeSection && filter.types.count == 0 ||
      section == levelSection && filter.levels.count == 0 ||
      section == trackSection && filter.tracks.count == 0 {
      return 0
    }
    return 44
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var item: ProgramListFilter.FilterItem!
    switch indexPath.section {
    case typeSection:
      item = filter.types[indexPath.row]
    case levelSection:
      item = filter.levels[indexPath.row]
    case trackSection:
      item = filter.tracks[indexPath.row]
    default:
      return
    }
    item.mark = !item.mark
    tableView.deselectRow(at: indexPath, animated: true)
    tableView.reloadRows(at: [indexPath], with: .automatic)
  }
  
  private func checkmarkImage(marked: Bool) -> UIImage? {
    return marked ? UIImage(named: "ic-filter-checkmark-selected") : UIImage(named: "ic-filter-checkmark")
  }
}
