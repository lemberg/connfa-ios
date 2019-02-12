//
//  SpeakersListViewController.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 7/13/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit

class SpeakersListViewController: UIViewController {
  
  // MARK: - Private properties
  private let identifier = "speakerListCell"
  private let repository = FirebaseArrayRepository<SpeakerInList>()
  
  @IBOutlet weak var searchButton: UIBarButtonItem!
  @IBOutlet private var tableView: UITableView!
  
  private var speakersToShow = [String:[SpeakerInList]]()
  private var rightSearchBarButtonItem: UIBarButtonItem!
  
  private lazy var searchBar: UISearchBar = {
    let config = Configurations()
    self.rightSearchBarButtonItem = self.navigationItem.rightBarButtonItem
    self.rightSearchBarButtonItem.tintColor = config.tintColor
    let bar = UISearchBar()
    bar.sizeToFit()
    bar.delegate = self
    bar.searchBarStyle = UISearchBar.Style.minimal
    bar.tintColor = config.tintColor
    bar.placeholder = "Search speakers"
    return bar
  }()
  
  private lazy var emptySpeakersView: UIView = {
    let emptyView = EmptyStateView.instanceFromNib().forEmptyScreen(.sepeakers)
    emptyView.frame = tableView.frame
    return emptyView
  }()
  
  private lazy var emptySearchView: UIView = {
    let emptyView = EmptyStateView.instanceFromNib().forEmptyScreen(.speakersSearch)
    emptyView.frame = tableView.frame
    return emptyView
  }()
  
  private var allSpeakers = [SpeakerInList]() {
    didSet {
      speakersToShow = organize(speakers: allSpeakers)
    }
  }
  
  private var sortedHeaders: [String] {
    return speakersToShow.keys.sorted{ $0 < $1 }
  }
  
  private var numberOfSection: Int {
    return speakersToShow.keys.count
  }
  
  private var sectionIndexTitles: [String] {
    return sortedHeaders
  }
  
  private func organize(speakers: [SpeakerInList]) -> [String : [SpeakerInList]] {
    let uniqueHeaders = Set(speakers.map { $0.nameHeader })
    var result = [String : [SpeakerInList]]()
    uniqueHeaders.forEach { header in
      result[header.uppercased()] = speakers.filter { $0.nameHeader == header }
    }
    return result
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: .receiveSpeakers, object: nil)
    allSpeakers = repository.values
    navigationItem.titleView = NavigationTitleLabel(withText: "Speakers")
    setupNavBar(isTranslucent: true)
    updateUI()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    didChange(filter: nil)
  }
 
   override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    searchBar.resignFirstResponder()
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    hideSearchBar()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let vc = segue.destination as? SpeakerDetailViewController, let uniqueName = sender as? String {
      vc.speakerUniqueName = uniqueName
    }
  }
  
  //MARK: - Actions
  @IBAction func searchPressed(_ sender: Any) {
    showSearchBar()
  }
  
  @objc func updateUI(){
    allSpeakers = repository.values
    if !allSpeakers.isEmpty {
      setUI()
      reload()
    } else {
      setEmptyUI()
    }
  }
  
  //MARK: - Private functions
  private func setupNavBar(isTranslucent: Bool) {
    navigationController?.navigationBar.isTranslucent = isTranslucent
    navigationController?.navigationBar.shadowImage = UIImage()
  }
  
  private func numberOfRows(in section: Int) -> Int {
    return speakersToShow[sortedHeaders[section]]!.count
  }
  
  private func header(for section: Int) -> String {
    return sortedHeaders[section]
  }
  
  private func speaker(for row: Int, in section: Int) -> SpeakerInList {
    return speakersToShow[sortedHeaders[section]]![row]
  }
  
  private func didSelect(for row: Int, in section: Int) {
    performSegue(withIdentifier: SegueIdentifier.showSpeakerListSpeakerDetails.rawValue, sender: speaker(for: row, in: section).uniqueName)
  }
  
  private func didChange(filter: String?) {
    if let filterPhrase = filter, !filterPhrase.isEmpty {
      let filtered = allSpeakers.filter { $0.fullName.lowercased().contains(filterPhrase.lowercased()) || $0.organisationAndPosition.lowercased().contains(filterPhrase.lowercased())}
      speakersToShow = organize(speakers: filtered)
    } else {
      speakersToShow = organize(speakers: allSpeakers)
    }
    reload()
    if speakersToShow.isEmpty {
      setEmptySearchUI()
    } else {
      setUI()
    }
  }
  
  private func showSearchBar() {
    self.searchBar.becomeFirstResponder()
    navigationItem.setRightBarButton(nil, animated: true)
    navigationItem.titleView?.alpha = 0
    navigationItem.titleView = searchBar
    setupNavBar(isTranslucent: false)
    UIView.animate(withDuration: 0.2, delay: 0.2, options: .curveEaseOut, animations: {
      self.navigationItem.titleView?.alpha = 1
    })
  }
  
  private func hideSearchBar() {
    navigationItem.titleView?.alpha = 1
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn, animations: {
      self.navigationItem.titleView?.alpha = 0
    }, completion: { finished in
      self.searchBar.text = nil
      self.navigationItem.titleView = NavigationTitleLabel(withText: "Speakers")
      self.navigationItem.titleView?.alpha = 0
      self.navigationItem.setRightBarButton(self.searchButton, animated: true)
      UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
        self.navigationItem.titleView?.alpha = 1
        self.setupNavBar(isTranslucent: true)
      })
    })
  }
  
  private func setEmptySearchUI() {
    tableView.backgroundView = emptySearchView
  }
  
  private func setEmptyUI() {
    searchButton.isEnabled = false
    tableView.backgroundView = emptySpeakersView
    tableView.isUserInteractionEnabled = false
  }
  
  private func setUI() {
    searchButton.isEnabled = true
    tableView.backgroundView = nil
    tableView.isUserInteractionEnabled = true
  }
  
  private func reload() {
    tableView.reloadData()
  }
}

extension SpeakersListViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return numberOfSection
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return numberOfRows(in: section)
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = SpeakersSectionView.instanceFromNib()
    view.abreviationLabel.text = header(for: section)
    return view
  }
  
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return sectionIndexTitles
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! SpeakerListTableViewCell
    cell.fill(with: speaker(for: indexPath.row, in: indexPath.section))
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    didSelect(for: indexPath.row, in: indexPath.section)
  }
}

extension SpeakersListViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    didChange(filter: searchText)
  }
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(true, animated: true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(false, animated: true)
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()    
    hideSearchBar()
    didChange(filter: nil)
  }
}
