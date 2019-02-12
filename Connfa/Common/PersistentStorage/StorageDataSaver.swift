//
//  StorageDataSaver.swift
//  Connfa
//
//  Created by Hellen Soloviy on 6/21/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation

class StorageDataSaver<Element: Codable> {
  
  private var key: String {
    return String(describing: Element.self)
  }
  
  var savedObject: Element? {
    let decoder = JSONDecoder()
    if let data = UserDefaults.standard.data(forKey: key) {
      do {
        let unarchiveFilter = try decoder.decode(Element.self, from: data)
        return unarchiveFilter
      } catch(let error) {
        print("FILTER GET error ___ \(error)")
        return nil
      }
    } else  {
      return nil
    }
  }
  
  func save(_ object: Element) {
    let coder = JSONEncoder()
    do {
      let data = try coder.encode(object)
      UserDefaults.standard.set(data, forKey: key)
      UserDefaults.standard.synchronize()
    } catch(let error) {
      print("FILTER SET error ___ \(error)")
      return
    }
  }
  
  func clean() {
    UserDefaults.standard.set(nil, forKey: key)
    UserDefaults.standard.synchronize()
  }
}
