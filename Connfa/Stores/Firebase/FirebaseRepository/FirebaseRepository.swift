//
//  FirebaseRepository.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/12/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation
import Firebase

protocol FirebaseRepositoryProtocol {
  associatedtype T
  var values: [T] { get }
  var firstValue: T? { get }
  var getParser: (DataSnapshot)->[T] { get }
  func valueBy(id: String) -> T?
}

class FirebaseRepository<Model: FirebaseModel>: FirebaseRepositoryProtocol {
  
  typealias T = Model
  
  let ref = Database.database().reference().child(Keys.startDate).child(T.keyPath)
  
  private(set) var models: [Model] = []
  
  var getParser: (DataSnapshot)->[Model] {
    assertionFailure("This is abstract method which should be overridden")
    func stub(snapshot: DataSnapshot)->[Model] { return [] }
    return stub
  }
  
  private var snapshot: DataSnapshot? {
    didSet {
      guard snapshot != nil else { return }
      parseSnapshot(by: getParser)
    }
  }
  
  public var values: [Model] {
    return models
  }
  
  public var firstValue: Model? {
    return models.first
  }
  
  public func valueBy(id: String) -> Model? {
    return models.filter{ $0.id == id }.first
  }
  
  private func setupObservations() {
    ref.observe(.value) { (snapshot) in
      self.snapshot = snapshot
    }
  }
  
  private func parseSnapshot(by parse: @escaping (DataSnapshot)->[Model]) {
    DispatchQueue.global(qos: .userInitiated).async {
      self.models = parse(self.snapshot!)
      DispatchQueue.main.async {
        guard let notification = T.notification else { return }
        NotificationCenter.default.post(name: notification, object: nil, userInfo: nil)
      }
    }
  }
  
  init() {
    setupObservations()
  }
  deinit {
    ref.removeAllObservers()
  }
}

class FirebasePropertiesRepository<Model: FirebaseModel>: FirebaseRepository<Model> {
  override var getParser: (DataSnapshot) -> [Model] {
    //parser for properties
    func parser(snapshot: DataSnapshot)->[Model] {
      var models: [Model] = []
      let dict = snapshot.value as? [String: Any]
      let key = snapshot.key
      if let model = Model.init(dictionary: dict, key: key) {
        models.append(model)
      }
      return models
    }
    return parser
  }
}

class FirebaseArrayRepository<Model: FirebaseModel>: FirebaseRepository<Model> {
  override var getParser: (DataSnapshot) -> [Model] {
    //parser for arrays
    func parser(snapshot: DataSnapshot) -> [Model] {
      var models: [Model] = []
      for child in snapshot.children {
        let snapshot = child as! DataSnapshot
        let dict = snapshot.value as? [String: Any]
        let key = snapshot.key
        if let model = Model.init(dictionary: dict, key: key) {
          models.append(model)
        }
      }
      return models
    }
    return parser
  }
}
