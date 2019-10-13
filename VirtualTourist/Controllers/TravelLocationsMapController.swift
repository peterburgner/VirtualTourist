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
    var annotations = [MKPointAnnotation]()
    
    // MARK: -View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        prepareUI()
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = location
        annotations.append(newAnnotation)
        mapView.addAnnotations(annotations)
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
    
    // -MARK: -IBActions
    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        }
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
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print(mapView.region)
        let regionData = ["latitude":mapView.region.center.latitude, "longitude":mapView.region.center.longitude, "latitudeDelta": mapView.region.span.latitudeDelta, "longitudeDelta":mapView.region.span.longitudeDelta]
        UserDefaults.standard.setValue(regionData, forKey: "regionData")
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        showPhotos(annotation: view.annotation as! MKPointAnnotation)
    }
    
    func showPhotos(annotation: MKAnnotation) {
        let vc = storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumController") as! PhotoAlbumController
        vc.annotation = annotation
        print("Annotation set to: \(vc.annotation)")
        navigationController!.pushViewController(vc, animated: true)
    }
}
