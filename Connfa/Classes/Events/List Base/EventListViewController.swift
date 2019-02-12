//
//  EventListViewController.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/30/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

class EventListViewController: UIViewController {
  @IBOutlet private weak var collection: UICollectionView!
  @IBOutlet weak var dayContainer: UIView!
  @IBOutlet weak var dayContainerHeight: NSLayoutConstraint!
  var additionalHeight: CGFloat = 0
  
  lazy var emptyEventsView: EmptyStateView = {
    let emptyView = EmptyStateView.instanceFromNib()
    emptyView.frame = collection.frame
    return emptyView
  }()
  var emptyView: UIView {
    return emptyEventsView
  }
  var events: [EventModel] {
    return repository.models
  }
  var initialSelectedDay: ProgramListDayViewData? {
    let today = Date()
    if let day = days.first(where: { Calendar.current.isDate( $0.origin, inSameDayAs: today) }) {
      return day
    } else {
      return self.days.first
    }
  }
  lazy var transformer = EventsViewModelsTransformer.default
  var fullList = [ProgramListDayViewData : DayList]()
  
  //MARK: - Private properties
  private weak var daysViewController: ProgramListDaysViewController!
  private var selectedDay: ProgramListDayViewData?
  private var shouldScrollDayList = true
  private var topInset: CGFloat {
    return dayContainer.frame.maxY + additionalHeight
  }
  private var bottomInset: CGFloat {
    return tabBarController?.tabBar.frame.height ?? 0
  }
  private let repository = FirebaseArrayRepository<EventModel>()
  private let daysContainerHeightConstant: CGFloat = 81
  
  //MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    collection.register(UINib(nibName: ProgramListCollectionCell.indentifier, bundle: nil), forCellWithReuseIdentifier: ProgramListCollectionCell.indentifier)
    setupNavBar()
    setLoadingState()
    setupObserving()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? ProgramListDaysViewController {
      daysViewController = destination
      daysViewController.delegate = self
      daysViewController.datasource = self
    }
    
    if let nvc = segue.destination as? UINavigationController, let destination = nvc.viewControllers.first as? ProgramDetailsViewController, let id = sender as? String, let event = events.first(where: { $0.id == id }) {
      destination.event = event
    }
  }
  
  //MARK: - Public functions
  func initialLoad() {
    invalidateDataSource()
    reload()
  }
  
  func setEmptyUI() {
    collection.backgroundView = emptyView
    collection.isUserInteractionEnabled = false
    dayContainerHeight.constant = 0
    dayContainer.isHidden = true
  }
  
  func setUI() {    
    collection.backgroundView = nil
    collection.isUserInteractionEnabled = true
    dayContainer.isHidden = false
    dayContainerHeight.constant = daysContainerHeightConstant
  }
  
  func reload() {
    self.collection.reloadData()
    self.daysViewController.reload()
    let day = selectedDay
    if let day = day, !days.isEmpty {
      var dayToSelect = day
      var indexToSelect = 0
      if let index = days.index(of: day) {
        indexToSelect = index
      } else {
        indexToSelect = days.count - 1
        dayToSelect = days[indexToSelect]
      }
      daysViewController.selectDay(dayToSelect, animated: false)
      collection.scrollToItem(at: IndexPath(row: indexToSelect, section: 0), at: .centeredHorizontally, animated: false)
    }    
  }
  
  func checkOnEmptiness() {
    if days.count == 0 {
      setEmptyUI()
    } else {
      setUI()
    }
  }
  
  //MARK - Actions
  @objc func receiveEvents() {
    initialLoad()
    checkOnEmptiness()
  }
  
  @objc func likeEvent(_ notification: Notification) {}
  
  //MARK: - Private functions
  private func event(by identifier: String) -> EventModel? {
    if let index = self.events.index(where: {$0.id == identifier}) {
      return self.events[index]
    } else {
      return nil
    }
  }
  
  private func collectionDidScroll(to index: Int) {
    let allDays = days
    if allDays.count > 0 {
      let day = allDays[min(allDays.count-1, max(0, index))]
      selectedDay = day
    }
  }
  
  private func dayList(for dayItem: Int) -> DayList {
    let day = self.days[dayItem]
    return fullList[day]!
  }
  
  private func invalidateDataSource() {
    self.fullList = self.transformer.transform(self.events)
    if let day = self.selectedDay, !self.days.isEmpty {
      if !self.days.contains(day) {
        self.selectedDay = self.days[max(self.days.count-1, 0)]
      }
    } else {
      self.selectedDay = self.initialSelectedDay
    }
  }
  
  private func setupNavBar() {
    navigationController?.navigationBar.isTranslucent = true
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
  }
  
  private func setLoadingState() {
    let view = UIActivityIndicatorView(style: .gray)
    view.startAnimating()
    collection.backgroundView = view
  }
  
  private func select(day: ProgramListDayViewData?) {
    if let day = day, let index = days.index(of: day) {
      shouldScrollDayList = false
      self.collection.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: true)
    }
  }
    
    private func setupObserving() {
        NotificationCenter.default.addObserver(self, selector: #selector(receiveEvents), name: .receiveEvent , object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(likeEvent(_:)), name: .interestedAdded , object: nil)
    }
}

extension EventListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return days.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collection.dequeueReusableCell(withReuseIdentifier: "ProgramListCollectionCell", for: indexPath) as! ProgramListCollectionCell
    let inset = UIEdgeInsets(top: topInset, left: 0, bottom: bottomInset, right: 0)
    cell.tableController.addContentInset(inset)
    cell.tableController.delegate = self
    cell.tableController.dayList = dayList(for: indexPath.item)
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let cell = cell as! ProgramListCollectionCell
    cell.tableController.tableView.setContentOffset(CGPoint(x: 0, y: -topInset), animated: false)
    cell.tableController.scrollToActualEvent()
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if shouldScrollDayList {
      let index = Int(round(scrollView.contentOffset.x / scrollView.bounds.size.width))
      collectionDidScroll(to: index)
      daysViewController.selectDay(selectedDay)
    }
  }
  
  func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    shouldScrollDayList = true
  }
}

extension EventListViewController: ProgramListDaysDataSource, ProgramListDaysDelegate {
  var days: [ProgramListDayViewData] {
    return Array(fullList.keys).sorted { $0.origin < $1.origin }
  }
  func programListDays(_ days: ProgramListDaysViewController, didSetectNew date: ProgramListDayViewData?) {
    selectedDay = date
    select(day: date)
  }
}

extension EventListViewController: BaseEventTableControllerDelegate {
  func didSelect(eventId: String) {
    performSegue(withIdentifier: SegueIdentifier.presentProgramDetails.rawValue, sender: eventId)
  }
  
  func tableView(willRemoveEvent eventId: String) -> Bool {
    if let vc = self as? InterestedListViewController, vc.isOwnPin {
      let prevDay = selectedDay
      invalidateDataSource()
      if selectedDay != prevDay {
        reload()
        checkOnEmptiness()
      }
      return true
    } else {
      return false
    }
  }
}
