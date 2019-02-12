//
//  ProgramListCell.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/21/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProgramListCell: UITableViewCell {
  
  @IBOutlet private weak var name: UILabel!
  @IBOutlet private weak var type: UILabel!
  @IBOutlet private weak var track: UILabel!
  @IBOutlet private weak var speakers: UILabel!
  @IBOutlet private weak var place: UILabel!
  @IBOutlet private weak var level: UIImageView!
  @IBOutlet private weak var frieandsInterested: UIImageView!
  @IBOutlet private weak var interestedBtn: UIButton!
  @IBOutlet private weak var speakersImg: UIImageView!
  @IBOutlet private weak var placeImg: UIImageView!

  @IBOutlet private weak var interestBoard: UIView!
  @IBOutlet private weak var background: UIImageView!
  @IBOutlet private weak var speakersToTrack: NSLayoutConstraint!
  @IBOutlet private weak var placeToSpeakers: NSLayoutConstraint!
  @IBOutlet private weak var interestToPlace: NSLayoutConstraint!
  @IBOutlet private weak var trackToName: NSLayoutConstraint!
  
  private var eventId: String!  
  
  @IBAction func onInterested() {
    InterestedFirebase.shared.updateInterested(for: eventId) { (error) in
      if let error = error {
        SVProgressHUD.showError(withStatus: error.description)
      }
    }
  }
  
  public func fill(with event: ProgramListViewData) {
    self.eventId = event.eventId    
    
    name.text = event.name
    fill(type, with: event.type)
    
    InterestedFirebase.shared.requestInterested(eventId: eventId) { [weak self] (isInterested, id) in
      if self?.eventId == id {
        isInterested ? self?.like() : self?.unlike()
      }
    }
    
    frieandsInterested.isHidden = true
    InterestedFirebase.shared.checkFriendIntersted(eventId: eventId) { [weak self] (hasFriends, id) in
      if self?.eventId == id {
        self?.frieandsInterested.isHidden = !hasFriends
      }
    }
    
    let hasTrack = fill(track, with: event.track)
    let hasSpeakes = fill(speakers, with: event.speakers)
    let hasPlace = fill(place, with: event.place)
    let hasLevel = fillLevel(with: event.levelImageName)
    
    if hasSpeakes {
      speakersImg.isHidden = false
      speakersToTrack.constant = 21
    } else {
      speakersImg.isHidden = true
      speakersToTrack.constant = -21
    }
    
    if hasPlace {
      placeImg.isHidden = false
      placeToSpeakers.constant = 19
    } else {
      placeImg.isHidden = true
      placeToSpeakers.constant = -21
    }
    
    if !hasLevel && !hasTrack {
      trackToName.constant = -21
    } else {
      trackToName.constant = 22
    }
    
    if !event.isSelectable {
      self.background.isHidden = true
      self.isUserInteractionEnabled = false
      interestedBtn.isHidden = true
      interestToPlace.constant = -24
    } else {
      self.background.isHidden = false
      self.isUserInteractionEnabled = true
      interestedBtn.isHidden = false
      interestToPlace.constant = 10
    }
  }
  
  public func changeBackground(image: UIImage) {
    self.background.image = image
  }
  
  func like() {
    interestedBtn.setImage(image(for: true), for: .normal)
    interestedBtn.setTitleColor(color(for: true), for: .normal)
  }
  
  func unlike() {
    interestedBtn.setImage(image(for: false), for: .normal)
    interestedBtn.setTitleColor(color(for: false), for: .normal)
  }
  
  //MARK: - private
  private func image(for interested: Bool) -> UIImage {
    let sufix = interested ? "active" : "inactive"
    return UIImage(named: "ic-interest-star-\(sufix)") ?? UIImage()
  }
  
  private func color(for interested: Bool) -> UIColor {
    return interested ? UIColor(hexString: "E64A19") : UIColor(hexString: "757575")
  }
  
  @discardableResult private func fill(_ label: UILabel, with value: String?) -> Bool {
    if let value = value, !value.isEmpty {
      label.isHidden = false
      label.text = value
      return true
    } else {
      label.isHidden = true
      return false
    }
  }
  
  private func fillLevel(with value: String?) -> Bool {
    if let eventLevelImageName = value {
      level.isHidden = false
      level.image = UIImage(named: eventLevelImageName)
      return true
    } else {
      level.isHidden = true
      return false
    }
  }
}
