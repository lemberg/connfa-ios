//
//  SpeakerDetailViewController.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 7/18/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit
import SVProgressHUD

protocol SpeakerDetailsDataSourceDelegate: BaseEventTableControllerDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView)
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

class SpeakerDetailViewController: UIViewController {
  
  // MARK: - Public properties
  var speakerUniqueName: String!
    
  @IBOutlet weak var tableView: EventsTableView!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var organizationAndPositionLabel: UILabel!
  @IBOutlet weak var photoImageView: UIImageView!
  @IBOutlet weak var abbreviationLabel: UILabel!
  @IBOutlet weak var expandableButton: UIButton!
  @IBOutlet weak var websiteButton: UIButton!
  @IBOutlet weak var twitterButton: UIButton!
  @IBOutlet weak var textView: UITextView!
  
  @IBOutlet weak var blurViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var titleTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
  @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
  
  // MARK: - Private properties
  private var previousScrollOffset: CGFloat = 0
  private var previousTitleTopHeight: CGFloat = 0
  private var previousImageTopHeight: CGFloat = 0
  private var minHeaderHeight: CGFloat = 155
  private var maxHeaderHeight: CGFloat!
  private var maxImageHeight: CGFloat!
  private var shouldCalculate: Bool = true
  private var isExpanding: Bool = false
  private var speaker: SpeakerDetail!
  private var tableController: SpeakerDetailEventTableController!
  
  private var range: CGFloat {
    return maxHeaderHeight - minHeaderHeight
  }
  
  private var contentHeightFits: Bool {
    tableController.tableView.layoutIfNeeded()
    return view.frame.height - minHeaderHeight > tableController.tableView.contentSize.height
  }
  
  private var contentInset: CGFloat = 0 {
    didSet {
      let inset = UIEdgeInsets(top: contentInset, left: 0, bottom: 0, right: 0)
      tableController.addContentInset(inset)
    }
  }
  
  private var speakerNameHeight : CGFloat {
    let width = nameLabel.frame.width
    var height = nameLabel.frame.height
    if width > 0 {
      let size = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
      height = nameLabel.sizeThatFits(size).height
    }
    return height
  }
  
  private var isExpendableButtonHidden: Bool {
    return speaker?.characteristic?.isEmpty ?? true
  }
  
  private lazy var emptyEventsView: EmptyStateView = {
    let emptyView = EmptyStateView.instanceFromNib().forEmptyScreen(.speakerDetail)
    emptyView.frame = CGRect(x: 0, y: maxHeaderHeight, width: view.frame.width, height: view.frame.height - maxHeaderHeight)
    emptyView.backgroundColor = #colorLiteral(red: 0.9529411765, green: 0.9529411765, blue: 0.9529411765, alpha: 1)
    return emptyView
  }()
  
  private lazy var transformer = SpeakerEventsViewModelsTransformer.default
  
  private var events: [EventModel] {
    return eventRepository.eventsFor(speakerUniqueName: speakerUniqueName)
  }
  
  private let speakerRepository = SpeakerDetailFirebaseRepository()
  private let eventRepository = EventFirebaseRepository()
  
  private func setHeader(collapsed: Bool) {
    UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
      let height = collapsed ? self.minHeaderHeight : self.maxHeaderHeight!
      self.blurViewHeightConstraint.constant = height
      self.contentInset = height
      self.updateHeaderView(withHeight: height)
      self.view.layoutIfNeeded()
    })
  }
  
  private func updateHeaderView(withHeight: CGFloat) {
    let diff = withHeight - maxHeaderHeight
    titleTopConstraint.constant = previousTitleTopHeight + diff
    imageTopConstraint.constant = previousImageTopHeight + diff / 2
    let newHeight = maxImageHeight + diff / 2
    imageHeightConstraint.constant = newHeight
    abbreviationLabel.layer.cornerRadius = newHeight / 2
    let percentage = (withHeight - minHeaderHeight) / range
    let alpha = pow(percentage, 6)
    photoImageView.alpha = alpha
    abbreviationLabel.alpha = alpha
    expandableButton.isHidden = withHeight != maxHeaderHeight || isExpendableButtonHidden
  }
  
  private func scrollViewDidStopScrolling() {
    guard shouldCalculate else { return }
    let midPoint = minHeaderHeight + (range / 2)
    setHeader(collapsed: blurViewHeightConstraint.constant < midPoint)
  }
  
  // MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    tableController = SpeakerDetailEventTableController(tableView: tableView)
    tableController.delegate = self
    maxHeaderHeight = blurViewHeightConstraint.constant
    maxImageHeight = imageHeightConstraint.constant
    previousScrollOffset = blurViewHeightConstraint.constant
    previousTitleTopHeight = titleTopConstraint.constant
    previousImageTopHeight = imageTopConstraint.constant
    abbreviationLabel.layer.cornerRadius = self.abbreviationLabel.bounds.size.width / 2
    abbreviationLabel.layer.borderWidth = 1.0
    abbreviationLabel.layer.borderColor = Configurations().tintColor.cgColor
    setupObservers()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    navigationController?.setNavigationBarHidden(false, animated: true)
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let nvc = segue.destination as? UINavigationController, let destination = nvc.viewControllers.first as? ProgramDetailsViewController, let id = sender as? String, let event = events.first(where: { $0.id == id }) {
      destination.event = event
    }
  }
  
  // MARK: - Actions
  @IBAction func expandButtonTapped(_ sender: UIButton) {
    isExpanding = true
    expandableButton.isEnabled = false
    shouldCalculate = false
    tableView.isUserInteractionEnabled = false
    let frameHeight = view.frame.height
    let isExpanded = blurViewHeightConstraint.constant == frameHeight
    let diff = frameHeight - maxHeaderHeight
    expandableButton.rotate(isExpanded ? 0.0 : .pi)
    UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
      self.blurViewHeightConstraint.constant = isExpanded ? self.maxHeaderHeight : frameHeight
      self.textViewHeightConstraint.constant = isExpanded ? 0 : diff
      self.view.layoutIfNeeded()
    }, completion: { complete in
      self.expandableButton.isEnabled = true
      self.tableView.isUserInteractionEnabled = isExpanded
      self.shouldCalculate = isExpanded
      self.isExpanding = false
    })
  }
  
  @IBAction func close(_ sender: UIButton) {
    dismiss(animated: true)
  }
  
  @IBAction func openWebSite(_ sender: UIButton) {
    if let site = speaker.webSite, let url = URL(string: site), UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url, options: [:])
    } else {
      SVProgressHUD.showError(withStatus: "Invalid input URL")
    }
  }
  
  @IBAction func openTwitter(_ sender: UIButton) {
    guard let screenName = speaker.twitterName, let appURL = URL(string: "twitter://user?screen_name=\(screenName)"), let webURL = URL(string: "https://twitter.com/\(screenName)") else {
      return
    }
    let application = UIApplication.shared
    if application.canOpenURL(appURL) {
      application.open(appURL, options: [:])
    } else if application.canOpenURL(webURL) {
      application.open(webURL, options: [:])
    } else {
      SVProgressHUD.showError(withStatus: "Invalid input URL")
    }
  }
  
  @objc func receiveSpeaker() {
    speaker = speakerRepository.speakerBy(uniqueName: speakerUniqueName)
    configureHeaderView()
    if let url = speaker.avatarUrl {
      let circleFilter = ImageFilters.circle
      cacheImage(from: url, filter: circleFilter) { (image, _) in
        self.photoImageView.image = image
      }
    }
    let inset = UIEdgeInsets(top: blurViewHeightConstraint.constant, left: 0, bottom: 0, right: 0)
    tableController.addContentInset(inset)
    tableController.reload()
  }
  
  @objc func receiveEvent() {
    tableController.dayList = transformer.transform(events)
    if tableController.dayList.isEmpty {
      setEmptyState()
    } else {
      setRegularState()
    }
  }
  
  // MARK: - Private functions
  private func setEmptyState() {
    view.insertSubview(emptyEventsView, aboveSubview: tableView)
  }
  
  private func setRegularState() {
    if view.subviews.contains(emptyEventsView) {
      emptyEventsView.removeFromSuperview()
    }
  }
  
  private func configureHeaderView() {
    abbreviationLabel.text = speaker.abbreviation
    nameLabel.text = speaker.fullName
    organizationAndPositionLabel.text = speaker.organisationAndPosition
    expandableButton.isHidden = isExpendableButtonHidden
    twitterButton.isEnabled = !(speaker.twitterName?.isEmpty ?? true)
    websiteButton.isEnabled = !(speaker.webSite?.isEmpty ?? true)
    
    if let text = nameLabel.text, !text.isEmpty {
      let diff = (speakerNameHeight - nameLabel.frame.height)
      maxHeaderHeight = maxHeaderHeight + diff
      minHeaderHeight = minHeaderHeight + diff
      blurViewHeightConstraint.constant = blurViewHeightConstraint.constant + diff
      view?.layoutIfNeeded()
    }
    
    if let text = speaker.characteristic, !text.isEmpty {
      textView.contentInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
      let attributeText = NSMutableAttributedString(string: text)
      let textRange = NSMakeRange(0, attributeText.length)
      let font = UIFont(name: "SFUIText-Regular", size: 17)
      let color = UIColor(red: 117.0/255.0, green: 117.0/255.0, blue: 117.0/255.0, alpha: 1)
      let paragraphStyle = NSMutableParagraphStyle()
      paragraphStyle.lineSpacing = 5
      paragraphStyle.alignment = .center
      attributeText.addAttribute(.font, value: font as Any, range: textRange)
      attributeText.addAttribute(.paragraphStyle, value: paragraphStyle, range: textRange)
      attributeText.addAttribute(.foregroundColor, value: color, range: textRange)
      textView.attributedText = attributeText
    }
  }
    
  private func setupObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(receiveSpeaker), name: .receiveSpeakers , object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(receiveEvent), name: .receiveEvent , object: nil)
  }
}

extension SpeakerDetailViewController: SpeakerDetailsDataSourceDelegate {
  //MARK: - Dynamic header
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    guard shouldCalculate && !contentHeightFits else { return }
    let scrollDiff = scrollView.contentOffset.y - previousScrollOffset
    let absoluteTop: CGFloat = -blurViewHeightConstraint.constant
    let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
    
    let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
    let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
    
    self.previousScrollOffset = scrollView.contentOffset.y
    
    var newHeight = blurViewHeightConstraint.constant
    if isScrollingDown {
      newHeight = max(minHeaderHeight, blurViewHeightConstraint.constant - abs(scrollDiff))
    } else if isScrollingUp {
      newHeight = min(maxHeaderHeight, blurViewHeightConstraint.constant + abs(scrollDiff))
    }
    
    if newHeight != blurViewHeightConstraint.constant {
      blurViewHeightConstraint.constant = newHeight
      contentInset = newHeight
      updateHeaderView(withHeight: newHeight)
    }
  }
  
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    scrollViewDidStopScrolling()
  }
  
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      scrollViewDidStopScrolling()
    }
  }
  
  func didSelect(eventId: String) {
    performSegue(withIdentifier: SegueIdentifier.presentProgramDetails.rawValue, sender: eventId)
  }
}
