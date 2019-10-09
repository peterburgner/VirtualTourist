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
        // Prepare map
        print("Setting default")
//        print(UserDefaults.standard.float(forKey: "latitude"))
//            let coordinate = CLLocationCoordinate2D(latitude: regionData["latitude"], longitude: regionData["longitude"])
//            let region = MKCoordinateRegion(center: <#T##CLLocationCoordinate2D#>, span: <#T##MKCoordinateSpan#>)

//            mapView.setRegion(coordinateRegion as! MKCoordinateRegion, animated: true)

    }
    
    // MARK: -IBActions
    @IBAction func edit(_ sender: Any) {
    }
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print(mapView.region)
        UserDefaults.standard.set(mapView.region.center.latitude, forKey: "latitude") // TODO: Remove, for testing only
        let regionData = ["latitude":mapView.region.center.latitude, "longitude":mapView.region.center.longitude, "latitudeDelta": mapView.region.span.latitudeDelta, "longitudeDelta":mapView.region.span.longitudeDelta]
        UserDefaults.standard.setValue(regionData, forKey: "regionData")
        
        print("Read")
        let loadedData = UserDefaults.standard.dictionary(forKey: "regionData")
        let location = CLLocationCoordinate2D(latitude: loadedData!["latitude"] as! CLLocationDegrees, longitude: loadedData!["longitude"] as! CLLocationDegrees)
        let span = MKCoordinateSpan(latitudeDelta: loadedData!["latitudeDelta"] as! CLLocationDegrees, longitudeDelta: loadedData!["longitudeDelta"] as! CLLocationDegrees)
        let region = MKCoordinateRegion(center: location, span: span)
        print(region)
    }
}
