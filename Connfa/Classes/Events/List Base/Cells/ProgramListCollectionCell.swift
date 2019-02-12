//
//  ProgramListCollectionCell.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/28/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class ProgramListCollectionCell: UICollectionViewCell {
  static let indentifier = "ProgramListCollectionCell"
  
  @IBOutlet private weak var table: EventsTableView!
  
  var dayList: DayList! {
    didSet {
      table.delegate = tableController
      table.dataSource = tableController
      tableController.dayList = dayList
    }
  }
  var tableController: ProgramTableController!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    tableController = ProgramTableController(tableView: table)    
  }
  
  override func prepareForReuse() {
    table.delegate = nil
    table.dataSource = nil
  }
}
