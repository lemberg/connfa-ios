//
//  EmptyState.swift
//  Connfa
//
//  Created by Marian Fedyk on 1/31/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

enum EmptyState {
  case floorPlan
  case location
  case info
  case sepeakers
  case socialMedia
  case events
  case interested
  case speakerDetail
  case speakersSearch
  case noInternetConnection
  
  var emptyStateIcon: UIImage? {
    switch self {
    case .floorPlan:
      return #imageLiteral(resourceName: "ic-no-floor-plan")
    case .location:
      return #imageLiteral(resourceName: "ic_no_location")
    case .info:
      return #imageLiteral(resourceName: "ic_no_about")
    case .sepeakers:
      return #imageLiteral(resourceName: "ic_no_speakers")
    case .socialMedia:
      return #imageLiteral(resourceName: "ic_no_social_media")
    case .events:
      return #imageLiteral(resourceName: "ic_no_sessions")
    case .interested:
      return #imageLiteral(resourceName: "ic_no_my_schedule")
    case .speakerDetail:
      return #imageLiteral(resourceName: "calendar_icon")
    case .speakersSearch:
      return nil
    case .noInternetConnection:
      return nil
    }
  }
  
  var emptyStateDescription: String? {
    switch self {
    case .floorPlan:
      return "Currently there are no floor plans"
    case .location:
      return "Currently location is unavailable"
    case .info:
      return "Currently information is unavailable"
    case .sepeakers:
      return "Currently there are no speakers"
    case .socialMedia:
      return "Currently there are no tweets"
    case .events:
      return "No events to show"
    case .interested:
      return "No interested to show"
    case .speakerDetail:
      return "Speaker's performances information have not published yet"
    case .speakersSearch:
      return "No Search Results"
    case .noInternetConnection:
      return FirebaseError.noInternet.description
    }
  }
}
