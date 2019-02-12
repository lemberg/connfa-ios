//
//  EmptyStateView.swift
//  Connfa
//
//  Created by Marian Fedyk on 1/31/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {

  @IBOutlet weak var icon: UIImageView!
  @IBOutlet weak var emptyStateDescription: UILabel!
  
  private static let fileName = "EmptyStateView"
  
  static func instanceFromNib() -> EmptyStateView {
    let view = UINib(nibName: EmptyStateView.fileName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! EmptyStateView
    view.translatesAutoresizingMaskIntoConstraints = true    
    return view
  }
  
  func forEmptyScreen(_ screen: EmptyState) -> EmptyStateView {
    self.icon.image = screen.emptyStateIcon
    self.emptyStateDescription.text = screen.emptyStateDescription
    return self
  }
}
