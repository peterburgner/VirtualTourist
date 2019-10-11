//
//  PhotoAlbumController.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/8/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumController: UIViewController, MKMapViewDelegate {
    
    // MARK: - Variables
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    var annotation:MKAnnotation!
    
    override func viewDidLoad() {
        mapView.delegate = self
        prepareUI()
    }
    
    func prepareUI() {
        mapView.addAnnotation(annotation)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
    }
    
    // MARK: - MapViewDelegate
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
    
    // MARK: -IBActions
    @IBAction func createNewCollection(_ sender: Any) {
        // TODO: filter out previously shown photos
    }
    
}
