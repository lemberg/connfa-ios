//
//  UICollectionView+Generics.swift
//  StylesCloud
//
//  Created by Sergiy Loza on 12.04.17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit

extension ReusableCell where Self: UICollectionReusableView {
  
  static var cellIdentifier: String {
    return "\(Self.self)"
  }
}

extension UICollectionView {
  
  func registerHeader<T: UICollectionReusableView>(_: T.Type) where T:ReusableCell {
    let nib = UINib(nibName: T.cellIdentifier, bundle: nil)
    self.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.cellIdentifier)
  }
  
  func registerFotter<T: UICollectionReusableView>(_: T.Type) where T: ReusableCell {
    let nib = UINib(nibName: T.cellIdentifier, bundle: nil)
    self.register(nib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.cellIdentifier)
  }
  
  func dequeueReusableHeader<T: UICollectionReusableView>(for indexPath:IndexPath) -> T where T:ReusableCell {
    return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: T.cellIdentifier, for: indexPath) as! T
  }
  
  func dequeueReusableFotter<T: UICollectionReusableView>(for indexPath:IndexPath) -> T where T:ReusableCell {
    return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: T.cellIdentifier, for: indexPath) as! T
  }
  
  func registerCell<T: UICollectionViewCell>(_: T.Type) where T: ReusableCell {
    let nib = UINib(nibName: T.cellIdentifier, bundle: nil)
    self.register(nib, forCellWithReuseIdentifier: T.cellIdentifier)
  }
  
  func dequeueReusableCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableCell {
    return dequeueReusableCell(withReuseIdentifier: T.cellIdentifier, for: indexPath) as! T
  }
}

