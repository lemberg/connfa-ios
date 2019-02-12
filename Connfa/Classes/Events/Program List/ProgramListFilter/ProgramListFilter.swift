//
//  ProgramListFilter.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/24/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation

class ProgramListFilter: Codable {
  class FilterItem: Codable, Hashable {
    var title: String
    var mark = false
    
    var hashValue: Int {
      return title.hashValue
    }
    
    init(title: String) {
      self.title = title
    }
    
    static func == (lhs: ProgramListFilter.FilterItem, rhs: ProgramListFilter.FilterItem) -> Bool {
      return lhs.title == rhs.title
    }
  }
  
  var types: [FilterItem]
  var levels: [FilterItem]
  var tracks: [FilterItem]
  
  init(types: [String], levels: [String], tracks: [String]) {
    self.types = types.map { FilterItem(title: $0) }
    self.levels = levels.map { FilterItem(title: $0) }
    self.tracks = tracks.map { FilterItem(title: $0) }
  }
  
  convenience init() {
    self.init(types: [], levels: [], tracks: [])
  }
  
  public var isEmpty: Bool {
    return !needFilter(conditions: types) && !needFilter(conditions: levels) && !needFilter(conditions: tracks)
  }
  
  public func reset() {
    types.forEach { $0.mark = false }
    levels.forEach { $0.mark = false }
    tracks.forEach { $0.mark = false }
  }
  
  /// Merge new filter with existing one without loosing mark
  ///
  /// - Parameter filter: newFilter
  public func merge(with filter: ProgramListFilter) {
    let oldTypesSet = Set(self.types)
    let newTypesSet = Set(filter.types)
    
    let oldlevelsSet = Set(self.levels)
    let newlevelsSet = Set(filter.levels)
    
    let oldTracksSet = Set(self.tracks)
    let newTracksSet = Set(filter.tracks)
    
    let typesIntersec = oldTypesSet.intersection(newTypesSet)
    let levelsIntersec = oldlevelsSet.intersection(newlevelsSet)
    let tracksIntersec = oldTracksSet.intersection(newTracksSet)
    
    let typesSubstract = newTypesSet.subtracting(oldTypesSet)
    let levelsSubstract = newlevelsSet.subtracting(oldlevelsSet)
    let tracksSubstract = newTracksSet.subtracting(oldTracksSet)
    
    // Intersection
    var newTypes = self.types.filter{ typesIntersec.contains($0) }
    var newLevels = self.levels.filter{ levelsIntersec.contains($0) }
    var newTracks = self.tracks.filter{ tracksIntersec.contains($0) }
    
    // Union with substraction
    newTypes.append(contentsOf: typesSubstract)
    newLevels.append(contentsOf: levelsSubstract)
    newTracks.append(contentsOf: tracksSubstract)
    
    self.types = newTypes
    self.levels = newLevels
    self.tracks = newTracks
  }
  
  public func apply(for events: [EventModel]) -> [EventModel] {
    var result = events
    
    if needFilter(conditions: types) {
      let typeFilters = map(conditions: types)
      result = result.filter {
        if let type = $0.type {
          return typeFilters.contains(type)
        }
        return false
      }
    }
    
    if  needFilter(conditions: levels) {
      let levelFilters = map(conditions: levels)
      result = result.filter {
        let eventHasNoLevel = $0.experienceLevel < 0
        if eventHasNoLevel {
          return true
        }
        if let expLevel = ExperienceLevel(rawValue: $0.experienceLevel) {
          return levelFilters.contains(expLevel.description)
        }
        return false
      }
    }
    
    if needFilter(conditions: tracks) {
      let trackFilters = map(conditions: tracks)
      result = result.filter {
        if let track = $0.track {
          return trackFilters.contains(track)
        }
        return false
      }
    }
    
    return result
  }
  
  public var filterInfo: String {
    let adapter = ProgramListFilterAdapter()
    let infoTypes = map(conditions: types)
    let infoLevels = map(conditions: levels)
    let infoTracks = map(conditions: tracks)
    return adapter.fullString(types: infoTypes, specialTypeMarked: specialTypeMarked, levels: infoLevels, tracks: infoTracks)
  }
  
  /// Currently only events with type 'Session' has experiance levels: Beginner/Intermediate/Advanced.
  private let specialType = "Session"
  var specialTypeMarked: Bool {
    var result = false
    for item in types {
      if item.title == self.specialType && item.mark == true {
        result = true
        break
      }
    }
    return result
  }
  
  
  //MARK: - private
  /// Check if events needed to filter by conditions. There is no need to filter conditions in case all marked or all not marked. Filtering needed if only few marked.
  ///
  /// - Parameter conditions: Array of FilterItem for specific parameter type/level/track
  /// - Returns: true - need to filter / false - no need
  private func needFilter(conditions: [FilterItem]) -> Bool {
    let total = conditions.count
    let marked = conditions.filter { $0.mark }.count
    return !(marked == 0 || marked == total)
  }
  
  /// Map string values of FilterItems if it's marked
  ///
  /// - Parameter conditions: Array of FilterItem for specific parameter type/level/track
  /// - Returns: values fo filtering
  private func map(conditions: [FilterItem]) -> [String] {
    return conditions.compactMap{ $0.mark ? $0.title : nil }
  }
}
