//
//  AppDelegate.swift
//  Connfa
//
//  Created by Volodymyr Hyrka on 7/11/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit
import SVProgressHUD
import TwitterKit
//import ConnfaCore
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    SVProgressHUD.setDefaultStyle(.dark)
    SVProgressHUD.setDefaultMaskType(.gradient)
    SVProgressHUD.setDefaultAnimationType(.native)
    SVProgressHUD.setMinimumDismissTimeInterval(2.0)
    
    //OHTTPStub.setUp()
    let config = Configurations()
    
    if let key = config.twitterApiKey, let secret = config.twitterApiSecret {
      TWTRTwitter.sharedInstance().start(withConsumerKey: key, consumerSecret: secret)
    }
    
    //Initialize Firebase
    
    var filePath:String!
    
    #if DEBUG
    print("[FIREBASE] Development mode.")
    filePath = Bundle.main.path(forResource: "GoogleService-Info-Debug", ofType: "plist")
    #else
    print("[FIREBASE] Production mode.")
    filePath = Bundle.main.path(forResource: "GoogleService-Info-Release", ofType: "plist")
    #endif
    
    let options = FirebaseOptions(contentsOfFile: filePath)!
    FirebaseApp.configure(options: options)
    
    Database.database().isPersistenceEnabled = true    
    //Sign in anonimous user
    keepAllDataSynced()
    
    UINavigationBar.appearance().tintColor = config.tintColor
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    if let dynamicLink = DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) {
      self.handleIncomingDynamicLink(dynamicLink)
      return true
    }
    return false
  }
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { [weak self] (dynamiclink, error) in
      guard let strongSelf = self else { return }
      if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
        strongSelf.handleIncomingDynamicLink(dynamiclink)
      }
    }
    
    return handled
  }
  
  func handleIncomingDynamicLink(_ link: DynamicLink) {
    guard let queryDict = link.url?.queryDictionary, let id = queryDict[Keys.User.pinId] else { return }
    if let topVC = UIApplication.topViewController() {
      let storyboard = UIStoryboard(name: "Pin", bundle: nil)
      if let pinVC = storyboard.instantiateViewController(withIdentifier: PinViewController.storyboardID) as? PinViewController {
        pinVC.pin = Pin(pinId: id)
        pinVC.isEditState = false
        pinVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: pinVC, action: #selector(pinVC.close))
        let nvc = UINavigationController(rootViewController: pinVC)
        nvc.navigationBar.isTranslucent = true
        nvc.navigationBar.setBackgroundImage(UIImage(), for: .default)
        nvc.navigationBar.shadowImage = UIImage()
        topVC.present(nvc, animated: true)
      }
    }
  }

  func applicationWillResignActive(_ application: UIApplication) {
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
  }

  func applicationWillTerminate(_ application: UIApplication) {
    
  }

}

extension AppDelegate {
  private func keepAllDataSynced() {
    let database = Database.database().reference()
    database.child(EventModel.keyPath).keepSynced(true)
    database.child(InfoModel.keyPath).keepSynced(true)
    database.child(LocationModel.keyPath).keepSynced(true)
    database.child(SpeakerInList.keyPath).keepSynced(true)
    database.child(FloorPlanModel.keyPath).keepSynced(true)
    database.child(Keys.interested).keepSynced(true)
    
    // Cache floor plans images
    database.child(FloorPlanModel.keyPath).observeSingleEvent(of: .value, with: { (snapshot) in
      DispatchQueue.global(qos: .userInitiated).async {
        for child in snapshot.children {
          let snapshot = child as! DataSnapshot
          let dict = snapshot.value as! [String: Any]
          if let imageUrl = dict[Keys.FloorPlan.floorPlanImageURL] as? String {
            cacheImage(from: imageUrl)
          }
        }
      }
    })
    
    // Cache location image
    database.child(LocationModel.keyPath).observeSingleEvent(of: .value, with: { (snapshot) in
      DispatchQueue.global(qos: .userInitiated).async {
        for child in snapshot.children {
          let snapshot = child as! DataSnapshot
          let dict = snapshot.value as? [String: Any]
          if let imageUrl = dict?[Keys.Location.image] as? String {
            cacheImage(from: imageUrl)
          }
        }
      }
    })
    
    // Cache speakers images
    database.child(SpeakerInList.keyPath).observeSingleEvent(of: .value, with: { (snapshot) in
      DispatchQueue.global(qos: .userInitiated).async {
        for child in snapshot.children {
          let snapshot = child as! DataSnapshot
          let dict = snapshot.value as! [String: Any]
          if let imageUrl = dict[Keys.Speaker.avatarImageURL] as? String {
            cacheImage(from: imageUrl)
          }
        }
      }
    })
    
  }
}

