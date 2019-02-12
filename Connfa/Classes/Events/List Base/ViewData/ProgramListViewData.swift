//
//  ProgramListViewData.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 10/26/17.
//  Copyright (c) 2017 Lemberg Solution. All rights reserved.
//

import Foundation

typealias DayList = [ProgramListSlotViewData : [ProgramListViewData]]

struct ProgramListViewData {
  var eventId: String
  var name: String
  var isSelectable: Bool
  var place: String?
  var levelImageName: String?
  var type: String?
  var speakers: String?
  var track: String?  
}

struct SpeakerProgramListViewData {
  var eventId: String
  var name: String
  var place: String?
  var levelImageName: String?
  var type: String?
  var speakers: String?
  var track: String?
  var interested: Bool?
  var friendsInterested: Bool?
  var slot: ProgramListSlotViewData
}
