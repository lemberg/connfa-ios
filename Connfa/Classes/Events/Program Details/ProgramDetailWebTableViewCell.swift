//
//  WebProgramDetailsTableViewCell.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/18/17.
//

import UIKit

class ProgramDetailWebTableViewCell: UITableViewCell {
  
  @IBOutlet weak var webView: UIWebView!
  
  func fill(with event: EventModel, height: CGFloat) {
    let content = event.text
    webView.scrollView.isScrollEnabled = false
    webView.loadHTMLString(HTMLManager.makeDocument(withContent: content ?? "", withStyle: .event) ?? "", baseURL: Bundle.main.bundleURL)
    webView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: height))
    webView.setNeedsLayout()
    webView.layoutIfNeeded()
  }
  
}
