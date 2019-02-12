//
//  SpeakerListTableViewCell.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/11/17.
//

import UIKit

class SpeakerListTableViewCell: UITableViewCell {
  @IBOutlet weak var speakerImageView: UIImageView!
  @IBOutlet weak var speakerListFullNameLabel: UILabel!
  @IBOutlet weak var speakerListDetailLabel: UILabel!
  @IBOutlet weak var abbreviationLabel: UILabel!
  private var imageURL: String!
  
  func fill(with speaker: SpeakerInList) {
    setRoundedLabel()
    abbreviationLabel.text = speaker.abbreviation
    speakerListFullNameLabel.text = speaker.fullName
    speakerListDetailLabel.text = speaker.organisationAndPosition
    guard let url = speaker.avatarUrl else {
      speakerImageView.image = nil
      return
    }
    imageURL = url
    let circleFilter = ImageFilters.circle
    cacheImage(from: url, filter: circleFilter) { (image, key) in
      if key == self.imageURL {
        self.speakerImageView.image = image
      }
    }
  }
  
  private func setRoundedLabel() {
    self.abbreviationLabel.layer.cornerRadius = self.abbreviationLabel.bounds.size.width / 2
    self.abbreviationLabel.layer.borderWidth = 1.0
    self.abbreviationLabel.layer.borderColor = Configurations().tintColor.cgColor
  }
}
