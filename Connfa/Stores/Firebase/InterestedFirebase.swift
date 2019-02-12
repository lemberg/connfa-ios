//
//  InterestedFirebase.swift
//  Connfa
//
//  Created by Marian Fedyk on 1/2/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation
import Firebase
import EventKit

class InterestedFirebase {
  
  static let shared = InterestedFirebase()
  private let eventStorage = EventStorage()
  
  private init() {
    fetchSnapshot {}
    if let _ = UserFirebase.shared.ownPinId {
      setupObservers()
    } else {
      NotificationCenter.default.addObserver(self, selector: #selector(self.setupObservers), name: .signedIn , object: nil)
    }
  }
  
  typealias ErrorBlock = (_ error : FirebaseError?) -> ()
  typealias CompletionBlock = () -> ()
  typealias InterestedBlock = (_ isInterested: Bool, _ eventId: String) -> ()
  
  private let ref = Database.database().reference().child(Keys.startDate)
  
  private var interestedSnapshot: DataSnapshot?
  
  private var interestedReference: DatabaseReference {
    return ref.child(Keys.interested)
  }
  
  private var ownEventsSnapshot: DataSnapshot? {
    if let pin = UserFirebase.shared.ownPin?.pinId {
      return interestedSnapshot?.childSnapshot(forPath: pin)
    } else {
      return nil
    }
  }
  
  @objc private func setupObservers() {
    interestedReference.child(UserFirebase.shared.ownPinId!).observe(.childAdded) { (snapshot) in
      let dict = [Keys.Event.eventId: snapshot.key]
      self.fetchSnapshot {
        NotificationCenter.default.post(name: .interestedAdded, object: nil, userInfo: dict)
        NotificationCenter.default.post(name: .interestedChanged, object: nil, userInfo: dict)
      }
    }
    
    interestedReference.child(UserFirebase.shared.ownPinId!).observe(.childRemoved) { (snapshot) in
      let dict = [Keys.Event.eventId: snapshot.key]
      self.fetchSnapshot {
        NotificationCenter.default.post(name: .interestedRemoved, object: nil, userInfo: dict)
        NotificationCenter.default.post(name: .interestedChanged, object: nil, userInfo: dict)
      }
    }
  }
  
  func requestInterested(eventId: String, _ block: @escaping InterestedBlock) {
    DispatchQueue.global(qos: .userInitiated).async {
      var isInterested = false
      if let snapshot = self.ownEventsSnapshot {
        isInterested = snapshot.hasChild(eventId)
      }
      DispatchQueue.main.async {
        block(isInterested,eventId)
      }
    }
  }
  
  func contains(pinId: String, eventId: String) -> Bool {
    return interestedSnapshot?.childSnapshot(forPath: pinId).hasChild(eventId) ?? false
  }
  
  func update(_ block: @escaping CompletionBlock) {
    self.fetchSnapshot(block)
  }
  
  func isValid(_ id: String) -> Bool {
    return id.count == 4 && id.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
  }
  
  func checkFriendIntersted(eventId: String, _ block: @escaping InterestedBlock) {
    DispatchQueue.global(qos: .userInitiated).async {
      var isInterested = false
      if let pinsSnap = self.interestedSnapshot {
        for pin in UserFirebase.shared.pins {
          if pinsSnap.childSnapshot(forPath: pin.pinId).hasChild(eventId) && pin != UserFirebase.shared.ownPin {
            isInterested = true
            break            
          }
        }
      }
      DispatchQueue.main.async {
        block(isInterested,eventId)
      }
    }
  }
  
  func friendsInterestedInEvent(eventId: String) -> [String] {
    if let pinsSnap = interestedSnapshot {
      return UserFirebase.shared.pins
        .filter{ pinsSnap.childSnapshot(forPath: $0.pinId).hasChild(eventId) && $0 != UserFirebase.shared.ownPin }
        .map{ $0.actionTitle }
    } else {
      return []
    }
  }
  
  func updateInterested(for eventId: String,_ block: @escaping ErrorBlock) {
    guard let pin = UserFirebase.shared.ownPin?.pinId else {
      block(.noPin)
      return
    }
    let eventRef = interestedReference.child(pin).child(eventId)
    requestInterested(eventId: eventId) { (isInterested, id) in
      if id == eventId {
        if isInterested {
          eventRef.removeValue()
          self.eventStorage.removeFromCalendarEvents(ids: [eventId])
        } else {
          eventRef.setValue(true)
          self.eventStorage.addToCalendarEvents(ids: [eventId])
        }
      }
    }
    block(nil)
  }
  
  private func fetchSnapshot(_ block: @escaping CompletionBlock) {
    interestedReference.observeSingleEvent(of: .value) { (snapshot) in
      self.interestedSnapshot = snapshot
      DispatchQueue.main.async {
        block()
      }      
    }
  }
}
