//
//  ProgramListDayCell.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 10/27/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class ProgramListDayCell: UICollectionViewCell, ReusableCell {
  @IBOutlet var day: UILabel!
  
  override var isSelected: Bool{
    didSet{
      if self.isSelected
      {
        day.textColor = UIColor.white
        day.font = UIFont(name: "SFUIText-Semibold", size: 17)
        day.backgroundColor = UIColor(red: 230.0/255, green: 74.0/255, blue: 25.0/255, alpha: 1.0)
      }
      else
      {
        day.textColor = UIColor.black
        day.font = UIFont(name: "SFUIText-Regular", size: 17)
        day.backgroundColor = UIColor.clear
      }
    }
  }
}
