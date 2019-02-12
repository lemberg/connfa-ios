//
//  UITableView+Generics.swift
//  StylesCloud
//
//  Created by Sergiy Loza on 02.03.17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

extension ReusableCell where Self:UITableViewCell {
  
  static var cellIdentifier: String {
    return "\(Self.self)"
  }
}

protocol ReusableHeaderFooterView {
  static var reuseIdentifier: String { get }
}

extension ReusableHeaderFooterView where Self:UITableViewHeaderFooterView {
  
  static var reuseIdentifier: String {
    return "\(Self.self)"
  }
}

extension UITableView {  
  func registerHeaderFooterView<T: UITableViewHeaderFooterView>(_: T.Type) where T: ReusableHeaderFooterView {
    let nib = UINib(nibName: T.reuseIdentifier, bundle: nil)
    self.register(nib, forHeaderFooterViewReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueHeaderFooterView<T: UITableViewHeaderFooterView>() -> T where T: ReusableHeaderFooterView {
    return dequeueReusableHeaderFooterView(withIdentifier: T.reuseIdentifier) as! T
  }
  
  func registerCell<T: UITableViewCell>(_: T.Type) where T: ReusableCell {
    let nib = UINib(nibName: T.cellIdentifier, bundle: nil)
    self.register(nib, forCellReuseIdentifier: T.cellIdentifier)
  }
  
  func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableCell {
    return dequeueReusableCell(withIdentifier: T.cellIdentifier, for: indexPath) as! T
  }
}
