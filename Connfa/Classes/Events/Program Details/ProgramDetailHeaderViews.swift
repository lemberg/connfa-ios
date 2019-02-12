//
//  ProgramDetailHeaderViews.swift
//  Connfa
//
//  Created by Marian Fedyk on 9/15/17.
//

import UIKit

protocol ExpandableHeaderViewDelegate: class {
  func toggleSection(_ interestedHeaderView: ProgramDetailInterestHeaderView)
}

class BaseProgramDetailHeaderView: UITableViewHeaderFooterView {
  
  @IBOutlet weak var headerViewTitle: UILabel!
  
  private var sectionBackgroundView: UIView {
    let view = UIView()
    view.backgroundColor = UIColor.white
    return view
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    backgroundView = sectionBackgroundView
  }
}

class ProgramDetailInterestHeaderView: BaseProgramDetailHeaderView {
  weak var delegate: ExpandableHeaderViewDelegate?
  
  @IBOutlet weak var arrowImage: UIImageView!
  
  var isExtended = false {
    didSet {
      UIView.animate(withDuration: 0.25, animations: {
        self.arrowImage.transform = CGAffineTransform(rotationAngle: self.isExtended ? CGFloat.pi : 0.0)
      })
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectHeaderAction)))
  }
  
  override func awakeFromNib() {
    super.headerViewTitle.text = "Interested"
  }
  
  @objc func selectHeaderAction(gestureRecognizer: UITapGestureRecognizer) {
    delegate?.toggleSection(self)
  }
}

