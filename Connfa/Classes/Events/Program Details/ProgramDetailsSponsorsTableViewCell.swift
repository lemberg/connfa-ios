//
//  ProgramDetailsSponsorsTableViewCell.swift
//  Connfa
//
//  Created by Marian Fedyk on 2/12/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

class ProgramDetailsSponsorsTableViewCell: UITableViewCell {
  
  @IBOutlet private weak var firstImage: UIImageView!
  @IBOutlet private weak var secondImage: UIImageView!
  
  var firstURL: String = "" {
    didSet {
      setImage(firstURL, in: firstImage)
    }
  }
  var secondURL: String = "" {
    didSet {
      setImage(secondURL, in: secondImage)
    }
  }
  
  private func setImage(_ url: String, in view: UIImageView) {
    guard !url.isEmpty, let _ = URL(string: url) else { return }
    cacheImage(from: url) { (image, key) in
      if url == key {
        view.image = image        
      }
    }
  }
  
}
