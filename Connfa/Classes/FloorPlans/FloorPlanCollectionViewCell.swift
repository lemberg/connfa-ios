//
//  FloorPlanCollectionViewCell.swift
//  Connfa
//
//  Created by Marian Fedyk on 7/17/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit

class FloorPlanCollectionViewCell: UICollectionViewCell {
  let maximumZoomScale: CGFloat = 5.0
  let numberOfTaps: Int = 2
  
  @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet private weak var floorPlanScrollView: UIScrollView!
  @IBOutlet private weak var imageView: UIImageView!
    
  private var imageURL: String!
  
  private var image: UIImage? {
    didSet {
      imageView.image = image
      imageView.frame.origin = CGPoint.zero
      floorPlanScrollView.contentSize = self.imageView.bounds.size
      setZoomScale()
      setContentInsets()
    }
  }
  
  private lazy var minZoomScale: CGFloat = {
    floorPlanScrollView.bounds = self.bounds
    let widthScale = self.floorPlanScrollView.bounds.width / self.imageView.bounds.width
    let heightScale = self.floorPlanScrollView.bounds.height / self.imageView.bounds.height
    return min(widthScale, heightScale)
  }()
  
  override func awakeFromNib() {
    setupGestureRecognizer()
    floorPlanScrollView.delegate = self
    activityIndicator.startAnimating()
  }
  
  private func setupGestureRecognizer() {
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction))
    doubleTap.numberOfTapsRequired = numberOfTaps
    floorPlanScrollView.addGestureRecognizer(doubleTap)
  }
  
  private func setZoomScale() {
    floorPlanScrollView.maximumZoomScale = maximumZoomScale
    floorPlanScrollView.minimumZoomScale = minZoomScale
    floorPlanScrollView.zoomScale = minZoomScale
  }
  
  private func setContentInsets() {
    let verticalPading = imageView.frame.height < floorPlanScrollView.frame.height ? (floorPlanScrollView.frame.height - imageView.frame.height) / 2 : 0
    let horizontalPading = imageView.frame.width < floorPlanScrollView.frame.width ? (floorPlanScrollView.frame.width - imageView.frame.width) / 2 : 0
    floorPlanScrollView.contentInset = UIEdgeInsets(top: verticalPading, left: horizontalPading, bottom: verticalPading, right: horizontalPading)
  }
  
  private func zoomRectForScale(scale: CGFloat, center: CGPoint) -> CGRect {
    var zoomRect = CGRect.zero
    zoomRect.size.height = imageView.frame.size.height / scale
    zoomRect.size.width  = imageView.frame.size.width  / scale
    let newCenter = imageView.convert(center, from: floorPlanScrollView)
    zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
    zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
    return zoomRect
  }
  
  func fill(with floorPlan: FloorPlanModel) {
    imageURL = floorPlan.floorPlanImageURL
    imageView.image = nil
    activityIndicator.startAnimating()
    cacheImage(from: imageURL) { (image, key) in
      if key == self.imageURL {
        self.activityIndicator.stopAnimating()
        self.image = image
      }
    }
  }
  
  func zoomOut() {
    floorPlanScrollView.setZoomScale(minZoomScale, animated: false)
  }
  
  @objc func doubleTapAction(recognizer: UITapGestureRecognizer) {
    if floorPlanScrollView.zoomScale > minZoomScale {
      floorPlanScrollView.setZoomScale(minZoomScale, animated: true)
    } else {
      floorPlanScrollView.zoom(to : zoomRectForScale(scale: maximumZoomScale, center: recognizer.location(in: recognizer.view)), animated: true)
    }
  }
}

extension FloorPlanCollectionViewCell: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }  
}
