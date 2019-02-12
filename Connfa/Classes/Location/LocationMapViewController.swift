//
//  LocationMapViewController.swift
//  Connfa
//
//  Created by Marian Fedyk on 10/4/17.
//  Copyright © 2017 Lemberg Solution. All rights reserved.
//

import UIKit
import MapKit

class LocationMapViewController: UIViewController {
  @IBOutlet weak var mapView: MKMapView!
  
  var regularVisibleRect: MKMapRect = MKMapRect()
  
  weak var delegate: LocationViewControllerDelegate?
  override func viewDidLoad() {
    mapView.delegate = self
  }
  
  func centerMapOn(annotation: MKPointAnnotation) {
    if mapView.annotations.isEmpty {
      mapView.addAnnotation(annotation)
    }
    mapView.showAnnotations([annotation], animated: true)
    regularVisibleRect = mapView.visibleMapRect
  }
}

extension LocationMapViewController: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
    delegate?.regionDidChangeAnimated()
  }
  func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
    delegate?.regionWillChangeAnimated()
  }
}
