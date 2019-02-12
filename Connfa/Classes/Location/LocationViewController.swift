//
//  LocationViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 7/24/17.
//  Copyright (c) 2017 Lemberg Solution Ltd. All rights reserved.
//

import UIKit
import MapKit

protocol LocationViewControllerDelegate: class {
  func regionDidChangeAnimated()
  func regionWillChangeAnimated()
}

class LocationViewController: UIViewController {
  //MARK: - Private properties
  @IBOutlet weak var titlesContainerView: UIView!
  @IBOutlet weak var titlesView: UIView!
  @IBOutlet weak var addressLabel: UILabel!
  @IBOutlet weak var detailAddressLabel: UILabel!
  @IBOutlet weak var locationImageView: UIImageView!
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var offsetConstraint: NSLayoutConstraint!
  
  private let repository = FirebasePropertiesRepository<LocationModel>()
  
  private var panGesture: UIPanGestureRecognizer?
  private var tapGesture: UITapGestureRecognizer?
  private var titlesTapGesture: UITapGestureRecognizer?
  private var mapViewController: LocationMapViewController!
  private var animator: UIViewPropertyAnimator!
  private var isHidenTitleView = false
  
  private var offset: CGFloat {
    return isHidenTitleView ? imageHeightConstraint.constant : 0
  }
  
  private lazy var emptyLocationView: UIView = {
    let emptyView = EmptyStateView.instanceFromNib().forEmptyScreen(.location)
    emptyView.frame = view.frame
    return emptyView
  }()
  
  //MARK: - View lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(self.updateUI), name: .receiveLocations, object: nil)
    updateUI()
    setupGestureRecognizers()
    panGesture!.isEnabled = true
    tapGesture!.isEnabled = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tabBarController?.delegate = self
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    tabBarController?.delegate = nil
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    mapViewController = (segue.destination as! LocationMapViewController)
    mapViewController.delegate = self
  }
  
  //MARK: - Actions
  @objc func updateUI() {
    if let location = repository.firstValue {
      setupUI(withLocation: location)
    } else {
      setEmptyUI()
    }
  }
  
  @objc func tapOnMap(_ sender: UITapGestureRecognizer) {
    if !isHidenTitleView {
      panGesture?.isEnabled = false
      UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.6, animations: {
        self.offsetConstraint.constant = self.offset
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
      }, completion: { _ in
        self.isHidenTitleView = !self.isHidenTitleView
        self.panGesture?.isEnabled = true
      })
    }
  }
  
  @objc func tapOnTitles(_ sender: UITapGestureRecognizer) {
    if isHidenTitleView {
      panGesture?.isEnabled = false
      UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
        self.offsetConstraint.constant = self.offset
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
      }, completion: { _ in
        self.isHidenTitleView = !self.isHidenTitleView
        self.panGesture?.isEnabled = true
      })
    }
  }
  
  func pathButtonTapped() {
    guard let location = repository.firstValue else { return }
    let placeMark = MKPlacemark(coordinate: location.clLocationCoordinate2D)
    let mapItem = MKMapItem(placemark: placeMark)
    mapItem.name = location.name
    mapItem.openInMaps(launchOptions: nil)
  }
  
  @objc func handlePan(recognizer: UIPanGestureRecognizer) {
    guard locationImageView?.image != nil else { return }
    switch recognizer.state {
    case .began:
      animator = UIViewPropertyAnimator(duration: 0.8, curve: .easeInOut){
        self.offsetConstraint.constant = self.offset
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
      }
      animator.pauseAnimation()
    case .changed:
      let translation = recognizer.translation(in: titlesView)
      animator.fractionComplete = abs(translation.y) / imageHeightConstraint.constant
    case .ended:
      recognizer.isEnabled = false
      animator.addCompletion({ _ in
        recognizer.isEnabled = true
      })
      let yVelocity = recognizer.velocity(in: nil).y / 100
      let initialVelocity = CGVector(dx: 0, dy: yVelocity)
      let notCopmletedSlide = yVelocity > 0.0 && !isHidenTitleView || yVelocity <= 0.0 && isHidenTitleView
      if notCopmletedSlide {
        animator.isReversed = true
      } else {
        self.isHidenTitleView = !self.isHidenTitleView
      }
      let timingParameters = UISpringTimingParameters(dampingRatio: 0.9, initialVelocity: initialVelocity)
      animator.continueAnimation(withTimingParameters: timingParameters, durationFactor: 0)
    default:
      break
    }
  }
  
  //MARK: - Private functions
  private func setupGestureRecognizers() {
    panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan))
    tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnMap))
    titlesTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapOnTitles))
    titlesContainerView.addGestureRecognizer(panGesture!)
    titlesContainerView.addGestureRecognizer(titlesTapGesture!)
    containerView.addGestureRecognizer(tapGesture!)
  }
  
  private func setupUI(withLocation location: LocationModel?) {
    if let location = repository.firstValue {
      fillLabels(with: location)
      if let url = location.imageUrl {
        cacheImage(from: url) { (image, _) in
          self.fillImage(image)
        }
      }
      centerMapOn(location)
    }
  }
  private func centerMapOn(_ location: LocationModel){
    let annotation = MKPointAnnotation()
    annotation.coordinate = location.clLocationCoordinate2D
    annotation.title = location.streetAndNumber
    centerMapOn(annotation: annotation)
  }
  
  func setEmptyUI() {
    if !view.subviews.contains(emptyLocationView) {
      view.addSubview(emptyLocationView)
    }
  }
  
  func centerMapOn(annotation: MKPointAnnotation){
    if view.subviews.contains(emptyLocationView) {
      emptyLocationView.removeFromSuperview()
    }
    mapViewController.centerMapOn(annotation: annotation)
  }
  
  func fillLabels(with info: LocationModel) {
    addressLabel.text = info.name
    detailAddressLabel.text = info.address
  }
  
  func fillImage(_ image: UIImage?) {
    guard let image = image else { return }
    isHidenTitleView = false
    let height = (image.size.height * view.frame.width) / image.size.width
    imageHeightConstraint.constant = height
    offsetConstraint.constant = height
    let size = CGSize(width: view.frame.width, height: imageHeightConstraint.constant)
    let scaledImage = image.af_imageScaled(to: size)
    locationImageView.image = scaledImage
    view.layoutIfNeeded()
    let rect = self.mapViewController.regularVisibleRect
    let insets = UIEdgeInsets(top: imageHeightConstraint.constant, left: 0, bottom: 0, right: 0)
    self.mapViewController.mapView.setVisibleMapRect(rect, edgePadding: insets, animated: true)
  }
}

extension LocationViewController: LocationViewControllerDelegate {
  func regionDidChangeAnimated() {
    panGesture?.isEnabled = true
    tapGesture?.isEnabled = true
  }
  
  func regionWillChangeAnimated() {
    panGesture?.isEnabled = false
    tapGesture?.isEnabled = false
  }
}

extension LocationViewController: UITabBarControllerDelegate {
  func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
    navigationController?.popToRootViewController(animated: false)
  }
}
