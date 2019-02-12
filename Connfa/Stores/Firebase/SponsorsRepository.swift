//
//  SponsorsFirebaseProvider.swift
//  Connfa
//
//  Created by Marian Fedyk on 2/7/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class SponsorsRepository {
  private let storage = Storage.storage().reference()
  private let database = Database.database().reference()
  
  private let group = DispatchGroup()
  
  private var sponsorsSnapshot: DataSnapshot?
  private var images: [String] = []
  
  private var sponsorsReference: DatabaseReference {
    return database.child(Configurations().startDate).child(Keys.sponsors)
  }
  
  init() {
    setupObservers()
  }
  
  private func setupObservers() {
    sponsorsReference.observe(.value) { (snapshot) in
      if let dict = snapshot.value as? [String: String] {
        self.images = []
        let arr = Array(dict.values)
        arr.forEach {
          self.group.enter()
          self.storage.child($0).downloadURL { url, _ in
            if let urlString = url?.absoluteString {
              self.images.append(urlString)
              self.group.leave()
            }
          }
        }
        self.group.notify(queue: .main) {
          NotificationCenter.default.post(name: .sponsorsChanged, object: nil, userInfo: nil)
        }
      }
    }
  }
  
  func getRandomURLs(count: Int) -> [String] {
    guard count <= images.count else {
      return []
    }
    var copy = images
    var result: [String] = []
    var i = copy.count
    for _ in 0..<count {
      let index = arc4random_uniform(UInt32(max(0,i - 1)))
      result.append(copy[Int(index)])
      copy.remove(at: Int(index))
      i = i - 1
    }
    return result
  }

}
