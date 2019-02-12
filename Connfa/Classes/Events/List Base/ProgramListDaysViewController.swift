//
//  ProgramListDaysViewController.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 10/26/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit
import SwiftDate

protocol ProgramListDaysDelegate: class {
  func programListDays(_ days: ProgramListDaysViewController, didSetectNew date: ProgramListDayViewData?)
}

protocol ProgramListDaysDataSource: class {
  var days: [ProgramListDayViewData] { get }
}

class ProgramListDaysViewController: UIViewController {
  
  weak var delegate: ProgramListDaysDelegate?
  weak var datasource: ProgramListDaysDataSource!
  
  @IBOutlet fileprivate weak var collection: UICollectionView?
  @IBOutlet fileprivate weak var fullDate: UILabel?
  
  private var selectedDate: ProgramListDayViewData? {
    didSet {
      if let date = selectedDate {
        fullDate?.text = date.fullDate
      } else {
        fullDate?.text = nil
      }
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    collection?.register(UINib(nibName: ProgramListDayCell.cellIdentifier, bundle: nil), forCellWithReuseIdentifier: ProgramListDayCell.cellIdentifier)
    collection?.allowsMultipleSelection = false
  }
  
  //MARK: - internal
  func reload() {
    collection?.delegate = self
    collection?.dataSource = self
    collection?.reloadData()
    if let day = selectedDate, let index = datasource.days.index(of: day) {
      let indexPath = IndexPath(row: index, section: 0)
      collection?.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
  }
  
  func selectDay(_ day: ProgramListDayViewData?, animated: Bool = true) {
    guard selectedDate != day, let day = day else { return }
    selectedDate = day
    if let index = datasource.days.index(of: day) {
      let indexPath = IndexPath(row: index, section: 0)
      collection?.selectItem(at: indexPath, animated: animated, scrollPosition: .centeredHorizontally)
    }
  }
}

extension ProgramListDaysViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return datasource.days.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgramListDayCell.cellIdentifier, for: indexPath) as! ProgramListDayCell
    let item = datasource.days[indexPath.item]
    cell.day.text = "\(item.day)"
    cell.isSelected = item == selectedDate
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    collection?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    selectedDate = datasource.days[indexPath.item]
    delegate?.programListDays(self, didSetectNew: selectedDate)
  }
}
