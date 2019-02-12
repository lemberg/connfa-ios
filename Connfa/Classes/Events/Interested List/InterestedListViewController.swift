//
//  InterestedListViewController.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 11/29/17.
//  Copyright (c) 2017 Lemberg Solution. All rights reserved.
//

import UIKit
import SVProgressHUD

class InterestedListViewController: EventListViewController {
  
  //MARK: - Public properties
  override var events: [EventModel] {
    guard let pin = selectedPin?.pinId else { return [] }
    return super.events.filter{ InterestedFirebase.shared.contains(pinId: pin, eventId: $0.id) }
  }
  
  private var pins: [Pin] {
    return UserFirebase.shared.pins
  }
  
  var isOwnPin: Bool {
    return selectedPin == UserFirebase.shared.ownPin
  }
  
  private(set) var selectedPin = UserFirebase.shared.ownPin
  
  override var emptyView: UIView {
    return super.emptyEventsView.forEmptyScreen(.interested)
  }

  private lazy var titleButton: UIButton = {
    let button = UIButton(type: .custom)
    button.setTitleColor(UIColor.black, for: .normal)
    button.semanticContentAttribute = UISemanticContentAttribute.forceRightToLeft
    button.titleLabel?.font = UIFont(name: "SFUIText-Semibold", size: 17)
    button.setImage(nil, for: .disabled)
    button.setImage(UIImage(named: "ic-arrow-down"), for: .normal)
    button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -20)
    button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)
    button.addTarget(self, action: #selector(self.pinSelectorTapped), for: .touchUpInside)
    return button
  }()
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    selectedPin = pins.first{ $0 == selectedPin } ?? UserFirebase.shared.ownPin
    InterestedFirebase.shared.update {
      self.initialLoad()
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    if let vc = segue.destination as? PinViewController {
        if let selectedPin = sender as? Pin {
            vc.pin = selectedPin
            vc.isEditState = true
        } else {
            vc.pin = nil
            vc.isEditState = false
        }
    }
  }
  
  override func initialLoad() {
    super.initialLoad()
    checkOnEmptiness()
    setNavigationButtonTitle(selectedPin?.displayName ?? selectedPin?.pinId)
  }
  
  //MARK: - Actions
  override func receiveEvents() {
    if self.selectedPin == nil {
      selectedPin = UserFirebase.shared.ownPin
    }
    super.receiveEvents()
  }
  
  @objc override func likeEvent(_ notification: Notification) {
    super.likeEvent(notification)
    initialLoad()
  }
  
  @objc func pinSelectorTapped() {
    showActionControllerWith(pins: pins)
  }
  
  @IBAction func actionButtonTapped(_ sender: UIBarButtonItem) {
    showActionSheet()
  }
  
  //MARK: - Private functions
  private func showActionControllerWith(pins: [Pin]) {
    let pinsSheetController = UIAlertController(title: nil, message: Constants.Text.choosePinToShow, preferredStyle: .actionSheet)
    pins.forEach{ pin in
      pinsSheetController.addAction(UIAlertAction(title: pin.actionTitle, style: .default, handler: { _ in
        self.pinSelected(pin: pin)
      }))
    }
    let cancelAction = UIAlertAction(title: Constants.Text.cancel, style: .cancel)
    pinsSheetController.addAction(cancelAction)
    present(pinsSheetController, animated: true, completion: nil)
  }
  
  private func pinSelected(pin: Pin) {
    selectedPin = pin
    InterestedFirebase.shared.update {
      self.initialLoad()
    }
  }
  
  private func addPinTapped() {
    self.performSegue(withIdentifier: SegueIdentifier.showInterestedListViewControllerPinViewController.rawValue, sender: nil)
  }
  
  private func editPinTapped() {
    self.performSegue(withIdentifier: SegueIdentifier.showInterestedListViewControllerPinViewController.rawValue, sender: selectedPin)
  }
  
  private func deletePinTapped() {
    UserFirebase.shared.deletePin(pin: selectedPin!) { (error) in
      if let error = error {
        SVProgressHUD.showError(withStatus: error.description)
      } else {
        SVProgressHUD.showSuccess(withStatus: Constants.Text.deletedSuccessfully)
        self.selectedPin = UserFirebase.shared.ownPin
        self.initialLoad()
      }
    }
  }
  
  private func setNavigationButtonTitle(_ title: String?) {
    titleButton.setTitle(title ?? Constants.Title.interested, for: .normal)
    titleButton.isEnabled = title != nil
    titleButton.sizeToFit()
    navigationItem.titleView = titleButton
  }
  
  private func showActionSheet() {
    let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let sharePinTitle = Constants.Text.shareYourPin + " (\(UserFirebase.shared.ownPin?.pinId ?? "Unknown"))"
    
    let actionsWithOwnPin = [
      UIAlertAction(title: sharePinTitle, style: .default) { _ in
        UserFirebase.shared.sharePinByPresentingActivity(on: self)
      },
      UIAlertAction(title: Constants.Text.addPin, style: .default) { _ in
        self.addPinTapped()
      }
    ]
    
    let actionsWithNotOwnPin = [
      UIAlertAction(title: Constants.Text.editPin, style: .default) { _ in
        self.editPinTapped()
      },
      UIAlertAction(title: Constants.Text.remove, style: .destructive) { _ in
        self.deletePinTapped()
      },
      UIAlertAction(title: Constants.Text.addPin, style: .default) { _ in
        self.addPinTapped()
      }
    ]
    
    if isOwnPin {
      actionsWithOwnPin.forEach{ action in
        actionSheetController.addAction(action)
      }
    } else {
      actionsWithNotOwnPin.forEach{ action in
        actionSheetController.addAction(action)
      }
    }
    actionSheetController.addAction(UIAlertAction(title: Constants.Text.cancel, style: .cancel))
    present(actionSheetController, animated: true, completion: nil)
  }
}

