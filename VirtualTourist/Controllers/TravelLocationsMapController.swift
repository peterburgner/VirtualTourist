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
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }

    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
        if sender.state == .ended {
            showPhotos()
        }
    }

    func addAnnotation(location: CLLocationCoordinate2D){
            let annotation = MKPointAnnotation()
            annotation.coordinate = location
            self.mapView.addAnnotation(annotation)
    }
    
    func showPhotos() {
        let vc = self.storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumController") as! PhotoAlbumController
        self.navigationController!.pushViewController(vc, animated: true)
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
    
    
    // MARK: - MKMapViewDelegate

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }

        return pinView
    }

//    // This delegate method is implemented to respond to taps. It opens the system browser
//    // to the URL specified in the annotationViews subtitle property.
//    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
//        if control == view.rightCalloutAccessoryView {
//            let app = UIApplication.shared
//            if let toOpen = view.annotation?.subtitle! {
//                app.open(URL(string:toOpen)!, options: [:], completionHandler: nil)
//            }
//        }
//    }
}
