//
//  TravelLocationsMapController.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/8/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()

    }
    
    func prepareUI() {
        // Prepare map
//        mapView.centerCoordinate = placemark[0].location!.coordinate
//        map.addAnnotation(MKPlacemark(placemark: placemark[0]))
//        let region = MKCoordinateRegion(center: map.centerCoordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
//        map.setRegion(region, animated: true)
    }
}
