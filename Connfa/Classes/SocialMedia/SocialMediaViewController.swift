//
//  SocialMediaViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 7/27/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit
import TwitterKit

class SocialMediaViewController: TWTRTimelineViewController {
  //MARK: - Private properties
  private var previousBackgroundView: UIView?
  private lazy var emptySocialView: UIView = {
    let emptyView = EmptyStateView.instanceFromNib().forEmptyScreen(.socialMedia)
    emptyView.frame = tableView.frame
    return emptyView
  }()
  
  private lazy var noInternetView: UIView = {
    let emptyView = EmptyStateView.instanceFromNib().forEmptyScreen(.noInternetConnection)
    emptyView.frame = tableView.frame
    return emptyView
  }()
  
  //MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    timelineDelegate = self
    let client = TWTRAPIClient()
    self.dataSource = TWTRSearchTimelineDataSource(searchQuery: Configurations().twitterSearchQuery ?? "", apiClient: client)
  }  
}

extension SocialMediaViewController: TWTRTimelineDelegate {
  func timeline(_ timeline: TWTRTimelineViewController, didFinishLoadingTweets tweets: [Any]?, error: Error?) {
    if tweets?.isEmpty ?? true && tableView.numberOfRows(inSection: 0) == 0 {
      previousBackgroundView = tableView.backgroundView
      tableView.isUserInteractionEnabled = false
      tableView.backgroundView = UserFirebase.shared.isReachable ? emptySocialView : noInternetView
    } else {
      tableView.backgroundView = previousBackgroundView
      tableView.isUserInteractionEnabled = true
    }
  }
}
