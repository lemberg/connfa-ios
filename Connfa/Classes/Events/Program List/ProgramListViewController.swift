//
//  ProgramListViewController.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 10/26/17.
//  Copyright (c) 2017 Lemberg Solution. All rights reserved.
//

import UIKit
import SwiftDate

class ProgramListViewController: EventListViewController {
  
  //MARK: - Public properties
  var filter: ProgramListFilter = ProgramListFilter()
  override var emptyView: UIView {
    return super.emptyEventsView.forEmptyScreen(.events)
  }
  
  //MARK: - Private properties
  @IBOutlet private weak var filterInfo: UILabel!
  @IBOutlet private weak var filterInfoHeight: NSLayoutConstraint!
  
  private let filterInfoDefaultHeight: CGFloat = 67.0
  private let userStorage = StorageDataSaver<ProgramListFilter>()
  
  //MARK: - Public functions
  override func viewDidLoad() {
    super.viewDidLoad()
    navigationItem.titleView = NavigationTitleLabel(withText: Constants.Title.program)
  }
  
  override func setUI() {
    navigationItem.rightBarButtonItem?.isEnabled = true
    super.setUI()    
  }
  
  override func setEmptyUI() {
    navigationItem.rightBarButtonItem?.isEnabled = false
    super.setEmptyUI()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let destination = segue.destination as? ProgramListFilterViewController {
      destination.filter = self.filter
      destination.delegate = self
    }
  }
    
  //MARK: - Actions
  @IBAction func onFilter() {
    performSegue(withIdentifier: SegueIdentifier.presentProgramListFilter.rawValue, sender: nil)
  }
  
  @IBAction func onResetFilter() {
    handleFilterReset()
  }
  
  override func receiveEvents() {
    super.receiveEvents()
    let newFilter = createFilter(from: super.events)
    if let savedFilter = userStorage.savedObject {
      savedFilter.merge(with: newFilter)
      userStorage.save(savedFilter)
      filter = savedFilter
    } else {
      filter = newFilter
    }
    filterChanged()
  }
  
  //MARK: - private
  private func createFilter(from events: [EventModel]) -> ProgramListFilter {
    let types = Array(Set(events.compactMap { $0.type })).filter{ !$0.isEmpty }
    let experienceLevels = Set(events.compactMap({ $0.experienceLevel })).sorted()
    let levels = Array(experienceLevels.compactMap { ExperienceLevel(rawValue: $0)?.description }).filter{ !$0.isEmpty }
    let tracks = Array(Set(events.compactMap { $0.track })).filter{ !$0.isEmpty }
    return ProgramListFilter(types: types, levels: levels, tracks: tracks)
  }
  
  private func filterChanged() {
    self.fullList = transformer.transform(filter.apply(for:
      super.events))
    let info = filter.isEmpty ? "" : filter.filterInfo
    let height: CGFloat = filter.isEmpty ? 0.0 : filterInfoDefaultHeight
    reload(filterSummary: info, filterHeight: height)
  }
  
  private func reload(filterSummary: String?, filterHeight: CGFloat) {
    filterInfoHeight.constant = filterHeight
    additionalHeight = filterHeight
    filterInfo.text = filterSummary
    reload()
  }
  
  private func handleFilterReset() {
    userStorage.clean()
    filter.reset()
    filterChanged()
  }
}

extension ProgramListViewController: ProgramListFilterDelegate {
  func filter(_ controller: ProgramListFilterViewController, didChange filter: ProgramListFilter) {
    self.filter = filter
    userStorage.save(filter)
    self.filterChanged()
  }
}

