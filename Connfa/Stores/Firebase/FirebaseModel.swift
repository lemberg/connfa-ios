//
//  FirebaseModel.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

public typealias SnapshotDictionary = [String: Any]?

protocol SnapshotDictionaryInitable {
  init?(dictionary: SnapshotDictionary, key: String)
}

protocol FirebaseModel: SnapshotDictionaryInitable {
  static var keyPath: String { get }
  static var notification: Notification.Name? { get }
  var id: String! { get set }
}

extension FirebaseModel {
  static var notification: Notification.Name? {
    return nil
  }
}

protocol RelationFirebaseModel: FirebaseModel {
  var uniqueName: String! { get set }
}
