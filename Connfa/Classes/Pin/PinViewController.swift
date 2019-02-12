//
//  PinViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/27/17.
//  Copyright (c) 2017 Lemberg Solution. All rights reserved.
//

import UIKit
import SVProgressHUD

class PinViewController: UIViewController {
  
  //MARK: - Public properties
  static let storyboardID = "PinViewControllerID"
  
  var pin: Pin?
  var isEditState: Bool = false
  var childVC: PinTableViewController?
  
  @IBOutlet weak var saveButton: UIBarButtonItem!
  
  //MARK: - Lifecicle
  override func viewDidLoad() {
    super.viewDidLoad()
    setUI(id: pin?.pinId, displayName: pin?.displayName)
    navigationItem.title = isEditState ? Constants.Text.editPin : Constants.Text.addPin
  }
  
  //MARK: - Public functions
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? PinTableViewController {
      childVC = destination
    }
  }
  
  //MARK: - Actions
  @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
    if let vc = childVC, let id = vc.pinTextField.text {
      var name: String? = nil
      if let aName = vc.displayNameTextField.text, !aName.isEmpty {
        name = aName
      }
      let pin = Pin(pinId: id, displayName: name)
      showSpinner()
      guard isEditState || !UserFirebase.shared.pins.contains(pin) else {
        showError(error: "This schedule already exist")
        return
      }
      
      UserFirebase.shared.addPin(pin: pin) { (error) in
        if let error = error {
          self.showError(error: error.description)
        } else {
          self.showSuccess(message: Constants.Text.succeeded)
        }
      }
    }
  }
  
  @objc func close() {
    if isModal {
      dismiss(animated: true)
    } else {
      navigationController?.popViewController(animated: true)
    }
  }
  
  //MARK: - Private functions
  private func setUI(id: String?, displayName: String?) {
    childVC?.pinTextField.isEnabled = !isEditState
    childVC?.pinTextField.text = id
    childVC?.displayNameTextField.text = displayName
  }
  
  private func showSuccess(message: String) {
    SVProgressHUD.showSuccess(withStatus: message)
    close()
  }
  
  private func showError(error: String) {
    SVProgressHUD.showError(withStatus: error)
  }
  
  private func showSpinner() {
    SVProgressHUD.show()
  }
  
}
