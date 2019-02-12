//
//  ProgramDetailsTitleTableViewCell.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/22/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class ProgramDetailsTitleTableViewCell: UITableViewCell {
  
  @IBOutlet weak var eventTitle: UILabel!
  @IBOutlet weak var eventTrack: UILabel!
  @IBOutlet weak var experienceLevel: UILabel!
  
  func fill(with event: EventModel) {
    eventTitle.text = event.name
    experienceLevel.text = ExperienceLevel(rawValue: event.experienceLevel)?.description
    eventTrack.text = event.track
  }
  
}
