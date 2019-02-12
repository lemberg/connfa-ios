//
//  URL+queryDictionary.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/6/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation

extension URL {
  var queryDictionary: [String: String]? {
    guard let components = query?.components(separatedBy: "&").map({ $0.components(separatedBy: "=") }) else { return nil }
    return components.reduce(into: [String:String]()) { dict, pair in
      if pair.count == 2 {
        dict[pair[0]] = pair[1]
      }
    }
  }
}
