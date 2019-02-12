//
//  ProgramTableController.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/20/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

class ProgramTableController: BaseEventTableController {
  //MARK: - Actions
  @objc override func unlikeEvent(_ notification: Notification) {
    super.unlikeEvent(notification)
    if let id = notification.userInfo?[Keys.Event.eventId] as? String, let indexPath = indexPathForVisibleCell(with: id) {
      guard delegate?.tableView(willRemoveEvent: id) ?? false else { return }
      tableView.beginUpdates()
      dayList[sortedSlots[indexPath.section]]?.remove(at: indexPath.row)
      if dayList[sortedSlots[indexPath.section]]?.isEmpty ?? false {
        dayList.removeValue(forKey: sortedSlots[indexPath.section])
        tableView.deleteSections([indexPath.section], with: .fade)
      } else {
        tableView.deleteRows(at: [indexPath], with: .fade)
      }
      tableView.endUpdates()
    }
  }
}
