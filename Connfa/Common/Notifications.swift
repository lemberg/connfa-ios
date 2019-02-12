//
//  Notifications.swift
//  ConnfaCore
//
//  Created by Marian Fedyk on 8/3/17.
//  Copyright © 2016 Lemberg Solution. All rights reserved.
//

import Foundation

public extension Notification.Name {
  /// Notification name *receiveLocations*. Notifies observers when new locations is received.
  static let receiveLocations = Notification.Name("repositoryDidReceiveLocations")
  /// Notification name *receiveSpeakers*. Notifies observers when new speakers is received.
  static let receiveSpeakers = Notification.Name("repositoryDidReceiveSpeakers")
  /// Notification name *receiveFloorPlans*. Notifies observers when new floor plans is received.
  static let receiveFloorPlans = Notification.Name("repositoryDidReceiveFloorPlans")
  /// Notification name *receivePOI*. Notifies observers when new POI is received.
  static let receivePOI = Notification.Name("repositoryDidReceivePOI")
  /// Notification name *receiveInfo*. Notifies observers when new Info is received.
  static let receiveInfo = Notification.Name("repositoryDidReceiveInfo")
  /// Notification name *receiveEvent*. Notifies observers when new Info is received.
  static let receiveEvent = Notification.Name("repositoryDidReceiveEvent")
  /// Notification name *receiveSchedule*. Notifies observers when new Info is received.
  static let receiveSchedule = Notification.Name("repositoryDidReceiveSchedule")
  /// Notification name *receiveTitle*. Notifies observers when new Title is received.
  static let receiveTitle = Notification.Name("repositoryDidReceiveTitle")
  
  /// Notification name *updateCurrentContentLength*. Notifies observers when updateCurrentContentLength is received.
  static let updateCurrentContentLength = Notification.Name("updateCurrentContentLength")
  /// Notification name *didFinishCaching*. Notifies observers when didFinishCaching.
  static let didFinishCaching = Notification.Name("didFinishCaching")
  
  /// Notification name *receiveCacheLenght*. Notifies observers when receive cache lenght.
  static let receiveCacheLenght = Notification.Name("receiveCacheLenght")
  
  /// Notification name *receiveFloorPlanImages*. Notifies observers when receive Floor Plan Images.
  static let receiveFloorPlanImages = Notification.Name("receiveFloorPlanImages")
  /// Notification name *receiveSpeakerImages*. Notifies observers when receive Speakers Images.
  static let receiveSpeakerImages = Notification.Name("receiveSpeakerImages")
  
  /// Notification name *downloadFailed*. Notifies observers when downloadFailed.
  static let downloadFailed = Notification.Name("downloadFailed")
  
  /// Notification name *signedIn*. Notifies observers when user is signed in successfully.
  static let signedIn = Notification.Name("signedIn")
  /// Notification name *signedOut*. Notifies observers when user is signed in successfully.
  static let signedOut = Notification.Name("signedOut")
  /// Notification name *interestedChanged*. Notifies observers when interested changed.
  static let interestedChanged = Notification.Name("interestedChanged")
  /// Notification name *interestedAdded*. Notifies observers when interested added.
  static let interestedAdded = Notification.Name("interestedAdded")
  /// Notification name *interestedRemoved*. Notifies observers when interested removed.
  static let interestedRemoved = Notification.Name("interestedRemoved")
  /// Notification name *sponsorsChanged*. Notifies observers when sponsors changed.
  static let sponsorsChanged = Notification.Name("sponsorsChanged")
  /// Notification name *dismissed preloader*. Notifies observers when dismissed preloader.
  static let dismissedPreloader = Notification.Name("dismissedPreloader")
}
