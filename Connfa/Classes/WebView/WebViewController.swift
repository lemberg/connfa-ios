//
//  WebViewViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 7/28/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {  
  //MARK: - Public properties
  var viewData: WebViewData!
  //MARK: - Private properties
  private var webView: WKWebView!
  
  override func loadView() {
    webView = WKWebView()
    webView.contentMode = UIView.ContentMode.scaleAspectFit
    view = webView
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    webView.navigationDelegate = self
  }
  
  func reloadContent() {
    webView.loadHTMLString(viewData.htmlDocument ?? "", baseURL: Bundle.main.bundleURL)    
  }
}

extension WebViewController: WKNavigationDelegate {
  func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
    if let url = webView.url, UIApplication.shared.canOpenURL(url) {
      UIApplication.shared.open(url)
    }
    decisionHandler(.cancel)
  }
}
