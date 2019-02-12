//
//  SegueIdentifiers.swift
//  Connfa
//
//  Created by Marian Fedyk on 7/25/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import Foundation

/// enum contains Storyboard Segue Identifiers
public enum SegueIdentifier: String {
  
  //FloorPlanViewController
  case showFloorPlansFloorPlanFullScreen
  
  //SpeakersListViewController
  case showSpeakerListSpeakerDetails
  
  //ProgramDetailsViewController
  case presentProgramDetailsSpeakerDetails
  
  //ProgramListViewController
  case presentProgramDetails
  case presentProgramListFilter
  
  //MoreViewController
  case embedMoreViewControllerMoreTableViewController
  
  //MoreViewController
  case showMoreViewControllerVenueViewController
  
  //MoreViewController
  case showMoreViewControllerInfoViewController
  
  //InterestedListViewController
  case showInterestedListViewControllerPinViewController
}

