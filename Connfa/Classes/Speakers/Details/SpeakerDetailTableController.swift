//
//  SpeakerDetailTableController.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/19/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

class SpeakerDetailEventTableController: BaseEventTableController {  
  override init(tableView: EventsTableView) {
    super.init(tableView: tableView)
    tableView.isHidden = false
    tableView.showsVerticalScrollIndicator = false
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    (delegate as? SpeakerDetailsDataSourceDelegate)?.scrollViewDidScroll(scrollView)
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    (delegate as? SpeakerDetailsDataSourceDelegate)?.scrollViewDidEndDecelerating(scrollView)
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    (delegate as? SpeakerDetailsDataSourceDelegate)?.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate)
  }
}
