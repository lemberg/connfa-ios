//
//  SpeakersSectionView.swift
//  Connfa
//
//  Created by Marian Fedyk on 5/16/18.
//  Copyright © 2018 Lemberg Solution. All rights reserved.
//

import UIKit

class SpeakersSectionView: UIView {
  
  @IBOutlet weak var abreviationLabel: UILabel!
  
  private static let fileName = "SpeakersSectionHeaderView"
  
  static func instanceFromNib() -> SpeakersSectionView {
    let view = UINib(nibName: SpeakersSectionView.fileName, bundle: nil).instantiate(withOwner: nil, options: nil).first as! SpeakersSectionView
    return view
  }
}
