//
//  FirebaseError.swift
//  Connfa
//
//  Created by Marian Fedyk on 1/2/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import Foundation

enum FirebaseError {
  case noCurrentUser
  case invalidPin
  case noPin
  case noInternet
  
  var description: String {
    switch self {
    case .noCurrentUser:
      return Constants.Text.noCurrentUser
    case .invalidPin:
      return Constants.Text.invalidPin
    case .noPin:
      return Constants.Text.noPin
    case .noInternet:
      return Constants.Text.noInternet
    }
  }
}
