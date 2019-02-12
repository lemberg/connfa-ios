//
//  ProgramDetailsViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/13/17.
//  Copyright (c) 2017 Lemberg Solution. All rights reserved.
//

import UIKit
import SVProgressHUD

class ProgramDetailsViewController: UIViewController {
  
  //MARK: - Public properties
  @IBOutlet weak var toolBar: UIToolbar!
  @IBOutlet weak var interestedButton: UIButton!  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var place: UILabel!
  @IBOutlet weak var timeInterval: UILabel!
  @IBOutlet weak var date: UILabel!
  
  var event: EventModel!
  
  //MARK: - Private properties
  private let speakersRepository = SpeakerFirebaseRepository()
  private let sponsorsRepository = SponsorsRepository()
  private let sectionHeaderHeight: Float = 44.0
  
  private let appLogoCellIdentifier = "appLogoCellIdentifier"
  private let interestedSectionIdetifier = "interestedSectionHeader"
  private let baseSectionIdentifier = "baseSectionIdentifier"
  private let titleCellIdentifier = "titleCellIdentifier"
  private let speakerCellIdentifier = "speakerCellIdentifier"
  private let sponsorsCellIdentifier = "sponsorsCellIdentifier"
  private let webViewCellIdentifier = "webViewCellIdentifier"
  private let interestedCellIdentifier = "interestedCellIdentifier"
  private let baseHeaderFileName = "BaseHeaderProgramDetailsView"
  private let interestedHeaderFileName = "InterestedHeaderProgramDetailsView"
  private let appLogoCellFileName = "AppLogoTableViewCell"
  
  private var webContentHeight : CGFloat = 0
  private var isExtendedInterestedSection = false
  private var interested: [String] = []
  private var sponsors: [String] = []
  
  private var allSections: [ProgramDetailsSection?] {
    let largeSectionRowsNumber = 1 + (speakersFromEvent.count) + ((event.text == "" || event.text == nil) ? 0 : 1)
    return [ProgramDetailsSection(.logoSectionType), ProgramDetailsSection(.speakersAndWebAndTitleSectionType, rows: largeSectionRowsNumber), ProgramDetailsSection(.sponsorsSectionType, rows: sponsors.count.signum()), ProgramDetailsSection(.interestedSectionType, rows: interested.count)]
  }
  
  private var sections: [ProgramDetailsSection] {
    return allSections.compactMap{ $0 }
  }
  
  private var topBorder: CALayer {
    let topBorder = CALayer()
    topBorder.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0.5)
    topBorder.backgroundColor = UIColor.lightGray.cgColor
    return topBorder
  }
  
  private var dequeueWebView: ProgramDetailWebTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: webViewCellIdentifier) as! ProgramDetailWebTableViewCell
    cell.webView.delegate = self
    cell.fill(with: event, height: webContentHeight)
    return cell
  }
  
  private var activityVC: UIActivityViewController {
    let invitation = "Hey, just thought this may be interesting for you: "
    let url = URL(string: event.link ?? "")
    let activityVC = UIActivityViewController(activityItems: [invitation, url], applicationActivities: nil)
    activityVC.popoverPresentationController?.sourceView = self.view
    activityVC.excludedActivityTypes = [
      UIActivity.ActivityType.postToWeibo,
      UIActivity.ActivityType.print,
      UIActivity.ActivityType.assignToContact,
      UIActivity.ActivityType.saveToCameraRoll,
      UIActivity.ActivityType.addToReadingList,
      UIActivity.ActivityType.postToFlickr,
      UIActivity.ActivityType.postToVimeo,
      UIActivity.ActivityType.postToTencentWeibo
    ]
    return activityVC
  }
  
  private var speakersFromEvent: [SpeakerInList] {
    return speakersRepository.speakersFrom(eventUniqueName: event.uniqueName)
  }
  
  private var interestedCellHeight: CGFloat {
    let regularHeight: CGFloat = 44.0
    return isExtendedInterestedSection ? regularHeight : 0
  }
  
  //MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setupObservers()
    InterestedFirebase.shared.requestInterested(eventId: event.id) { [weak self] (isInterested, id) in
      if self?.event.id == id {
        isInterested ? self?.like() : self?.dislike()
      }
    }
    interested = InterestedFirebase.shared.friendsInterestedInEvent(eventId: event.id)
    sponsors = sponsorsRepository.getRandomURLs(count: 2)
    setHeaderLabels()
    configureToolBar()
    configureTableView()
    configureNavBar()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: animated)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let vc = segue.destination as? SpeakerDetailViewController, let uniqueName = sender as? String {
      vc.speakerUniqueName = uniqueName
    }
  }
  
  func isWebViewCell(indexPath: IndexPath) -> Bool {
    let section = sections[indexPath.section]
    return section.type == .speakersAndWebAndTitleSectionType && section.rowNumber - 1 == indexPath.row
  }
  
  func isTitleCell(indexPath: IndexPath) -> Bool {
    let section = sections[indexPath.section]
    return section.type == .speakersAndWebAndTitleSectionType && indexPath.row == 0
  }
  
  func heightForHeader(in section: Int) -> Float {
    return sections[section].type == .logoSectionType ? 0 : sectionHeaderHeight
  }
  
  func speaker(for indexPath: IndexPath) -> SpeakerInList {
    return speakersFromEvent[indexPath.row - 1]
  }
  
  //MARK: - Actions
  @objc func like() {
    interestedButton.isSelected = true
  }
  
  @objc func dislike() {
    interestedButton.isSelected = false
  }
  
  @objc func updateSpeakers() {
    if let section = sections.index(where: { (section) -> Bool in
      section.type == .speakersAndWebAndTitleSectionType
    }) {
      reload(section: section)
    }
  }
  
  @objc func updateInterested(_ notification: Notification) {
    interested = InterestedFirebase.shared.friendsInterestedInEvent(eventId: event.id)
    if let section = sections.index(where: { (section) -> Bool in
      section.type == .interestedSectionType
    }) {
      reload(section: section)
    }
  }
  
  @objc func updateSponsors() {
    sponsors = sponsorsRepository.getRandomURLs(count: 2)
    tableView?.reloadData()
  }
  
  @IBAction func shareButtonPressed(_ sender: UIBarButtonItem) {
    present(activityVC, animated: true, completion: nil)
  }
  
  @IBAction func close(_ sender: UIButton) {
    dismiss(animated: true)
  }
  
  @IBAction func interestedButtonTapped(_ sender: UIButton) {    
    interestedButton.isEnabled = false
    interestedButton.isSelected = !interestedButton.isSelected
    InterestedFirebase.shared.updateInterested(for: event.id) { (error) in
      if let error = error {
        SVProgressHUD.showError(withStatus: error.description)
      } else {
        self.interestedButton.isEnabled = true
      }
    }
  }
  
  //MARK: - Private functions
  private func reload(section: Int) {
    tableView?.reloadSections([section], with: .automatic)
  }
  
  private func configureNavBar() {
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.shadowImage = UIImage()
  }
  
  private func configureToolBar() {
    tabBarController?.tabBar.isHidden = true
    toolBar.isTranslucent = false
    toolBar.layer.addSublayer(topBorder)
  }
  
  private func configureTableView() {
    tableView.tableFooterView = UIView()
    tableView.separatorStyle = .none
    tableView.rowHeight = UITableView.automaticDimension
    tableView.register(UINib(nibName: interestedHeaderFileName, bundle: nil), forHeaderFooterViewReuseIdentifier: interestedSectionIdetifier)
    tableView.register(UINib(nibName: baseHeaderFileName, bundle: nil), forHeaderFooterViewReuseIdentifier: baseSectionIdentifier)
    tableView.register(UINib(nibName: appLogoCellFileName, bundle: nil), forCellReuseIdentifier: appLogoCellIdentifier)
    addInsets()
  }
  
  private func addInsets() {
    let inset = UIEdgeInsets(top: headerView.frame.height, left: 0, bottom: 0, right: 0)
    tableView.contentInset = inset
    tableView.scrollIndicatorInsets = inset
  }
  
  private func setHeaderLabels() {
    place.text = event.place ?? ""
    timeInterval.text = DateManager.programDetailsTimeIntervalString(first: event.fromDate, second: event.toDate)
    date.text = DateManager.programDetailsDateString(date: event.fromDate)
  }
  
  private func presentSpeakerDetails(for uniqueName: String) {
    performSegue(withIdentifier: SegueIdentifier.presentProgramDetailsSpeakerDetails.rawValue, sender: uniqueName)
  }
    
  private func setupObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateSpeakers), name: .receiveSpeakers, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateInterested(_:)), name: .interestedChanged, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.like), name: .interestedAdded, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.dislike), name: .interestedRemoved, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateSponsors), name: .sponsorsChanged, object: nil)
  }
}

extension ProgramDetailsViewController: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sections[section].rowNumber
  }
  
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    switch sections[section].type {
    case .interestedSectionType:
      let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: interestedSectionIdetifier) as! ProgramDetailInterestHeaderView
      sectionHeader.delegate = self
      sectionHeader.isExtended = isExtendedInterestedSection
      return sectionHeader
    case .speakersAndWebAndTitleSectionType:
      let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: baseSectionIdentifier) as! BaseProgramDetailHeaderView
      sectionHeader.headerViewTitle.text = event.type
      sectionHeader.headerViewTitle.textColor = Configurations().tintColor
      return sectionHeader
    case .sponsorsSectionType:
      let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: baseSectionIdentifier) as! BaseProgramDetailHeaderView
      sectionHeader.headerViewTitle.text = "Sponsors"
      sectionHeader.headerViewTitle.textColor = UIColor.black
      return sectionHeader
    default:
      return nil
    }
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat(heightForHeader(in: section))
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
    return CGFloat(heightForHeader(in: section))
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if sections[indexPath.section].type == .interestedSectionType {
      return interestedCellHeight
    } else if sections[indexPath.section].type == .sponsorsSectionType {
      return 60.0
    } else if isWebViewCell(indexPath: indexPath) {
      return webContentHeight > 15 ? webContentHeight - 15 : webContentHeight
    } else {
      return 70
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if sections[indexPath.section].type == .interestedSectionType {
      return CGFloat(interestedCellHeight)
    } else if sections[indexPath.section].type == .sponsorsSectionType {
      return 60.0
    } else if isWebViewCell(indexPath: indexPath) {
      return webContentHeight > 15 ? webContentHeight - 15 : webContentHeight
    } else {
      return UITableView.automaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if sections[indexPath.section].type == .speakersAndWebAndTitleSectionType {
      if isWebViewCell(indexPath: indexPath) {
        return dequeueWebView
      } else if isTitleCell(indexPath: indexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: titleCellIdentifier) as! ProgramDetailsTitleTableViewCell
        cell.fill(with: event)
        return cell
      } else {     
        let cell = tableView.dequeueReusableCell(withIdentifier: speakerCellIdentifier) as! ProgramDetailSpeakerTableViewCell
        cell.fill(with: speaker(for: indexPath))
        return cell
      }
    } else if sections[indexPath.section].type == .interestedSectionType {
      let cell = tableView.dequeueReusableCell(withIdentifier: interestedCellIdentifier) as! ProgramDetailInterestTableViewCell
      cell.interestedLabel.text = interested[indexPath.row]
      return cell
    } else if sections[indexPath.section].type == .logoSectionType {
      return tableView.dequeueReusableCell(withIdentifier: appLogoCellIdentifier)!
    } else if sections[indexPath.section].type == .sponsorsSectionType {
      let cell = tableView.dequeueReusableCell(withIdentifier: sponsorsCellIdentifier) as! ProgramDetailsSponsorsTableViewCell
      if sponsors.count > 1 {
        cell.firstURL = sponsors[0]
        cell.secondURL = sponsors[1]
      }
      return cell
    } else {
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if !isTitleCell(indexPath: indexPath) && !isWebViewCell(indexPath: indexPath) {
      presentSpeakerDetails(for: speaker(for: indexPath).uniqueName)
    }
  }
}

extension ProgramDetailsViewController: ExpandableHeaderViewDelegate {
  func toggleSection(_ interestedHeaderProgramDetailsView : ProgramDetailInterestHeaderView) {
    isExtendedInterestedSection = !isExtendedInterestedSection
    interestedHeaderProgramDetailsView.isExtended = isExtendedInterestedSection
    tableView.beginUpdates()
    tableView.endUpdates()
  }
}

extension ProgramDetailsViewController: UIWebViewDelegate {
  func webViewDidFinishLoad(_ webView: UIWebView) {
    let height = webView.scrollView.contentSize.height
    guard webContentHeight != height else { return }
    webContentHeight = height
    tableView.beginUpdates()
    tableView.endUpdates()
  }
  
  func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
    if navigationType == UIWebView.NavigationType.linkClicked {
      UIApplication.shared.open(request.url!, options: [:], completionHandler: nil)
      return false
    }
    return true
  }
}

