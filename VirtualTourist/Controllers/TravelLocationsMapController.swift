//
//  TravelLocationsMapController.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/8/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationsMapController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: -View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        prepareUI()
    }
    
    func prepareUI() {
        if UserDefaults.standard.dictionary(forKey: "regionData") != nil {
            let loadedData = UserDefaults.standard.dictionary(forKey: "regionData")
            let location = CLLocationCoordinate2D(latitude: loadedData!["latitude"] as! CLLocationDegrees, longitude: loadedData!["longitude"] as! CLLocationDegrees)
            let span = MKCoordinateSpan(latitudeDelta: loadedData!["latitudeDelta"] as! CLLocationDegrees, longitudeDelta: loadedData!["longitudeDelta"] as! CLLocationDegrees)
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
            print("Set region to \(region)")
        }
    }
    
    // MARK: -IBActions
    @IBAction func edit(_ sender: Any) {
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print(mapView.region)
        let regionData = ["latitude":mapView.region.center.latitude, "longitude":mapView.region.center.longitude, "latitudeDelta": mapView.region.span.latitudeDelta, "longitudeDelta":mapView.region.span.longitudeDelta]
        UserDefaults.standard.setValue(regionData, forKey: "regionData")
    }
}
