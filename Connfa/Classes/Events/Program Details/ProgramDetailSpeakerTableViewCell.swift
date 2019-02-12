//
//  SpeakerProgramDetailsTableViewCell.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/15/17.
//

import UIKit

protocol ProgramDetailsSpeakerCellDelegate: class {
  func speakerDetailsTapped(uniqueName: String)
}

class ProgramDetailSpeakerTableViewCell: UITableViewCell {
  @IBOutlet weak var speakerImageView: UIImageView!
  @IBOutlet weak var speakerListFullNameLabel: UILabel!
  @IBOutlet weak var speakerListDetailLabel: UILabel!
  @IBOutlet weak var abbreviationLabel: UILabel!
  private var imageURL: String!
  private var speakerUniqueName: String?
  
  weak var delegate: ProgramDetailsSpeakerCellDelegate?
  
  @IBAction func speakerInfoButtonTapped(_ sender: UIButton) {
    if let uniqueName = speakerUniqueName {
      delegate?.speakerDetailsTapped(uniqueName: uniqueName)
    }
  }
  
  func fill(with speaker: SpeakerInList) {
    speakerUniqueName = speaker.uniqueName
    setRoundedLabel()
    speakerImageView.isHidden = true
    abbreviationLabel.text = speaker.abbreviation
    abbreviationLabel.isHidden = false
    speakerListFullNameLabel.text = speaker.fullName
    speakerListDetailLabel.text = speaker.organisationAndPosition
    
    guard let url = speaker.avatarUrl else {
      return
    }
    
    imageURL = url
    let circleFilter = ImageFilters.circle
    cacheImage(from: imageURL, filter: circleFilter) { (image, key) in
      if key == self.imageURL, image != nil {
        self.abbreviationLabel.isHidden = true
        self.speakerImageView.isHidden = false
        self.speakerImageView.image = image
      } else {
        self.setRoundedLabel()
      }
    }
  }
  
  private func setRoundedLabel() {
    self.abbreviationLabel.layer.cornerRadius = self.abbreviationLabel.bounds.size.width / 2
    self.abbreviationLabel.layer.borderWidth = 1.0
    self.abbreviationLabel.layer.borderColor = Configurations().tintColor.cgColor
  }
}
