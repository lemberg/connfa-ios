//
//  BaseEventTableController.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/19/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

protocol BaseEventTableControllerDelegate: class {
  func didSelect(eventId: String)
  func tableView(willRemoveEvent: String) -> Bool
}

extension BaseEventTableControllerDelegate {
  func tableView(willRemoveEvent: String) -> Bool {
    return false
  }
}

class BaseEventTableController: NSObject {
  private let defaultBackgroundImage = UIImage(named: "ic-event-bg")
  private let highlightedBackground = UIImage(named: "ic-event-bg-active")
  
  var dayList: DayList = [:] {
    didSet {
      sortedSlots = Array(dayList.keys).sorted{ $0.end  < $1.end }.sorted{ $0.start < $1.start }
      tableView.delegate = self
      tableView.dataSource = self
      reload()
    }
  }
  
  weak var delegate: BaseEventTableControllerDelegate?
  var tableView: EventsTableView
  var sortedSlots: [ProgramListSlotViewData] = []
  
  init(tableView: EventsTableView) {    
    self.tableView = tableView
    super.init()
    tableView.delegate = self
    tableView.dataSource = self
    setupObserving()
  }
  
  func reload() {
    tableView.reloadData()
  }
  
  func scrollToActualEvent() {
    if let section = sortedSlots.firstIndex(where: { ($0.marker == ProgramListSlotViewData.Marker.going || $0.marker == ProgramListSlotViewData.Marker.upcoming ) }) {
      let indexPath = IndexPath(row: 0, section: section)
      tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
  }
  
  func addContentInset(_ inset: UIEdgeInsets) {
    tableView.contentInset = inset
  }
  
  func card(for indexPath: IndexPath) -> ProgramListViewData {
    let slot = sortedSlots[indexPath.section]
    return dayList[slot]![indexPath.row]
  }
  
  func indexPathForVisibleCell(with eventId: String) -> IndexPath? {
    guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return nil }
    var path: IndexPath? = nil
    
    for (section, slot) in sortedSlots.enumerated() {
      if dayList[slot]!.contains(where: { (event) -> Bool in
        event.eventId == eventId
      }) {
        let row = dayList[slot]!.sorted{ $0.name < $1.name }.index { (event) -> Bool in
          event.eventId == eventId
        }
        path = IndexPath(row: row!, section: section)
        guard visibleIndexPaths.contains(where: { $0 == path! }) else { return nil }
        return path
      }
    }
    return path
  }
  
  //MARK: - Actions
  
  @objc func unlikeEvent(_ notification: Notification) {
    if let id = notification.userInfo?[Keys.Event.eventId] as? String, let indexPath = indexPathForVisibleCell(with: id) {
      let cell = tableView.cellForRow(at: indexPath) as! ProgramListCell
      cell.unlike()
    }
  }
  
  @objc func likeEvent(_ notification: Notification) {
    if let id = notification.userInfo?[Keys.Event.eventId] as? String, let indexPath = indexPathForVisibleCell(with: id) {
      let cell = tableView.cellForRow(at: indexPath) as! ProgramListCell
      cell.like()
    }
  }
    
    //MARK: - Private
    private func setupObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(likeEvent(_:)), name: .interestedAdded , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(unlikeEvent(_:)), name: .interestedRemoved , object: nil)
    }
}

extension BaseEventTableController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let slot = sortedSlots[section]
    let slotList = dayList[slot] ?? []
    return slotList.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: EventsTableView.programListCellIdentifier, for: indexPath) as! ProgramListCell
    cell.fill(with: card(for: indexPath))
    let totalInSection = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
    let zPos = CGFloat(indexPath.item) / CGFloat(totalInSection)
    cell.layer.zPosition = zPos
    cell.selectionStyle = UITableViewCell.SelectionStyle.none
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return dayList.keys.count
  }
}

extension BaseEventTableController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: ProgramListHeader.identifier) as! ProgramListHeader
    header.layer.zPosition = CGFloat(section) + 1
    header.fill(with: sortedSlots[section])
    return header
  }
  
  func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
    return true
  }
  
  func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! ProgramListCell
    if let highlightedBackground = highlightedBackground {
      cell.changeBackground(image: highlightedBackground)
    }
  }
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! ProgramListCell
    if let defaultBackgroundImage = defaultBackgroundImage {
      cell.changeBackground(image: defaultBackgroundImage)
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = card(for: indexPath)
    delegate?.didSelect(eventId: item.eventId)
  }
}
