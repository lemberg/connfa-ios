//
//  UserFirebaseManager.swift
//  Connfa
//
//  Created by Marian Fedyk on 12/15/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import Foundation
import Firebase
import SVProgressHUD

extension UserDefaults {
  private var timezoneAlertHasBeenShownKey: String {
    return "com.connfa.timezoneAlertHasBeenShown"
  }
  
  var timezoneAlertHasBeenShown: Bool {
    get {
      return self.bool(forKey: timezoneAlertHasBeenShownKey)
    }
    set {
      set(newValue, forKey: timezoneAlertHasBeenShownKey)
      synchronize()
    }
  }
}

class UserFirebase {
  
  static let shared = UserFirebase()
  
  private init() {
    NotificationCenter.default.addObserver(self, selector: #selector(showLocalizationDiferenceAlertIfNeeded), name: .dismissedPreloader , object: nil)
  }
  
  typealias ErrorBlock = (_ error : FirebaseError?) -> ()
  typealias CompletionBlock = () -> ()
  
  private let ref = Database.database().reference()
  
  private var userSnapshot: DataSnapshot?
  
  private var usersReference: DatabaseReference {
    return ref.child(Keys.users)
  }
  
  private var currentUser: User? {
    return Auth.auth().currentUser
  }
  
  private var isAuthenticated: Bool {
    return currentUser != nil
  }
  
  var ownPinId: String?
  
  var userId: String? {
    return currentUser?.uid
  }
  
  var ownPin: Pin? {
    guard let id = ownPinId else { return nil }
    return Pin(pinId: id, displayName: Constants.Text.myInterested)
  }
  
  var pins: [Pin] {
    var summ: [Pin] = []
    if let snapshots = userSnapshot?.childSnapshot(forPath: Keys.pins).children.allObjects as? [DataSnapshot] {
      summ = snapshots.map({ (snapshot) -> Pin in
        let dict = snapshot.value as? [String: Any]
        let key = snapshot.key
        return Pin(dictionary: dict, key: key)
      })
    }
    if let pin = ownPin {
      summ.append(pin)
    }
    return summ
  }
  
  private(set) var isReachable: Bool = true
  
  func addPin(pin: Pin,_ block: @escaping ErrorBlock) {
    guard isReachable else {
      block(.noInternet)
      return
    }
    guard let id = UserFirebase.shared.userId else {
      block(.noCurrentUser)
      return
    }
    guard InterestedFirebase.shared.isValid(pin.pinId) else {
      block(.invalidPin)
      return
    }
    
    let refPins = UserFirebase.shared.ref.child(Keys.pins)
    refPins.observeSingleEvent(of: .value) { (snapshot) in
      if snapshot.hasChild(pin.pinId) {
        ///user is here
        let ref = self.usersReference.child(id).child(Keys.pins).child(pin.pinId)
        if pin.displayName == nil {
          ref.setValue(true)
        } else {
          ref.setValue([Keys.displayName: pin.displayName])
        }
        block(nil)
      } else {
        ///no user for this pin
        block(.noPin)
        return
      }
    }
  }
  
  func sharePinByPresentingActivity(on vc: UIViewController) {
    guard let pin = ownPin?.pinId else {
      SVProgressHUD.showError(withStatus: FirebaseError.noPin.description)
      return
    }
    if isReachable {
      var longDynamicLink: URL? = nil
      if let url = URL(string: "https://www.connfa.com/incomingParams?\(Keys.User.pinId)=\(pin)") {
        longDynamicLink = DynamicLinkComponents(link: url, domain: Constants.Links.dynamicDomain).url
      }
      var invitation = Constants.Text.invitation + pin
      if let link = longDynamicLink {
        invitation += "\nTap to proceed: \(link)"
      }
      let activityVC = UIActivityViewController(activityItems: [invitation], applicationActivities: nil)
        .withDefaultExcludedActivity()
      activityVC.popoverPresentationController?.sourceView = vc.view
      vc.present(activityVC, animated: true)
    } else {
      SVProgressHUD.showError(withStatus: "Internet connections is not available at this moment. Please, try later.")
    }
  }
  
  func deletePin(pin: Pin, _ block: @escaping ErrorBlock) {
    guard let id = userId else {
      block(.noCurrentUser)
      return
    }
    guard pin != ownPin else {
      block(.invalidPin)
      return
    }
    let ref = usersReference.child(id).child(Keys.pins).child(pin.pinId)
    ref.removeValue()
    block(nil)
  }
  
  func signIn() {
    guard !isAuthenticated else {
      print("You are already signed in")
      setupAuthRelatedObservers()
      observeConnection {}
      return
    }
    
    Auth.auth().signInAnonymously(completion: { (user, error) in
      if let error = error {
        SVProgressHUD.showError(withStatus: error.localizedDescription)
        guard !self.isAuthenticated, self.isReachable else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: {
          print("sign in")
          self.signIn()
        })
        print("Anonymous auth failed")
      } else {
        self.setupAuthRelatedObservers()
        print("Sign in succesful")
      }
    })
  }
  
  @objc private func showLocalizationDiferenceAlertIfNeeded() {
    let config = Configurations()
    if !UserDefaults.standard.timezoneAlertHasBeenShown && TimeZone.current.identifier != config.timeZoneIdentifier {
      let alert = UIAlertController(title: "Timezone", message: "Event dates are provided in (time zone of event): \(config.timeZoneIdentifier)", preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .cancel)
      alert.addAction(okAction)
      UIApplication.topViewController()?.present(alert, animated: true)
      UserDefaults.standard.timezoneAlertHasBeenShown = true
    }
  }
  
  private func signOut() {
    do {
      try Auth.auth().signOut()
      NotificationCenter.default.post(name: .signedOut, object: nil, userInfo: nil)
    } catch {
      SVProgressHUD.showError(withStatus: error.localizedDescription)
    }
  }
  
  func observeConnection(_ block: @escaping CompletionBlock) {
    ref.child(".info/connected").observe(.value, with: { snapshot in
      if snapshot.value as? Bool ?? false {
        self.isReachable = true
        block()
      } else {
        self.isReachable = false
      }
    })
  }
  
  private func setupAuthRelatedObservers() {
    guard let id = userId else { return }
    usersReference.child(id).observe(.value) { (snapshot) in
      self.userSnapshot = snapshot
    }
    usersReference.child(id).child(Keys.User.ownPin).observe(.value) { (snapshot) in
      if let pin = snapshot.value as? String {
        self.ownPinId = pin
        NotificationCenter.default.post(name: .signedIn, object: nil, userInfo: nil)
      }
    }
  }
}
