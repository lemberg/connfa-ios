//
//  ProgramListHeader.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/21/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class ProgramListHeader: UITableViewHeaderFooterView {
  static let identifier = "ProgramListHeader"
  
  @IBOutlet fileprivate weak var start: UILabel!
  @IBOutlet fileprivate weak var end: UILabel!
  @IBOutlet fileprivate weak var rightPanel: UIImageView!
  @IBOutlet fileprivate weak var rightMessage: UILabel!
  
  public func fill(with slot: ProgramListSlotViewData) {
    start.text = formatDateToSystemRepresentation(slot.start)
    end.text = formatDateToSystemRepresentation(slot.end)
    start.textColor = #colorLiteral(red: 0.9019607843, green: 0.2901960784, blue: 0.09803921569, alpha: 1)
    end.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
    
    switch slot.marker {
    case .none:
      rightPanel.isHidden = true
      rightMessage.isHidden = true
      start.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
      end.textColor = #colorLiteral(red: 0.4588235294, green: 0.4588235294, blue: 0.4588235294, alpha: 1)
    case .going:
      rightPanel.isHidden = false
      rightMessage.isHidden = false
      rightPanel.image = UIImage(named: "ic-going-now")
      rightMessage.text = "Going Now"
      rightMessage.textColor = UIColor.white
    case .upcoming:
      rightPanel.isHidden = false
      rightMessage.isHidden = false
      rightPanel.image = UIImage(named: "ic-upcoming")
      rightMessage.text = "Upcoming"
      rightMessage.textColor = UIColor.black
    case .dateString(let date):
      rightPanel.isHidden = false
      rightMessage.isHidden = false
      rightPanel.image = UIImage(named: "ic-upcoming")
      rightMessage.text = date
      rightMessage.textColor = UIColor.black
    }
  }
    
    private func formatDateToSystemRepresentation(_ date:  String) -> String {
        let formatString = DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: Locale.current)!
        let hasAMPM = formatString.contains("a")
        
        if hasAMPM {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            guard let dateForFormatting = dateFormatter.date(from: date) else {
                print("Error -- Can't perform date formatting! ")
                return date
            }
            dateFormatter.dateFormat = "hh:mm a"
            let formattedDateString = dateFormatter.string(from: dateForFormatting)
            return formattedDateString
        }
        
        return date
    }
}
