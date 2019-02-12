//
//  EventsTableView.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/18/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

class EventsTableView: UITableView {
  static let programListHeaderidentifier = "ProgramListHeader"
  static let programListCellIdentifier = "ProgramListCell"
  
  private var suplementaryView: UIImageView {
    let result = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 70))
    result.image = #imageLiteral(resourceName: "ic-neutral-logo")
    result.contentMode = .center
    return result
  }
  
  override init(frame: CGRect, style: UITableView.Style){
    super.init(frame: frame, style: style)
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }
  
  private func setup() {
    register(UINib(nibName: EventsTableView.programListHeaderidentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: EventsTableView.programListHeaderidentifier)
    register(UINib(nibName: EventsTableView.programListCellIdentifier, bundle: nil), forCellReuseIdentifier: EventsTableView.programListCellIdentifier)
    estimatedRowHeight = 120
    rowHeight = UITableView.automaticDimension
    backgroundView = nil
    backgroundColor = UIColor.clear
    showsVerticalScrollIndicator = true
    tableHeaderView = suplementaryView
    tableFooterView = suplementaryView
    if #available(iOS 11.0, *) {
      contentInsetAdjustmentBehavior = .never
    }
  }  
}
