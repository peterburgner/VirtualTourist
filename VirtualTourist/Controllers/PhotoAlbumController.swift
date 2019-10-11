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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var newCollectionButton: UIButton!
    var downloadedImageCounter = 0
    var numberImages = 0
    
    var annotation:MKAnnotation!
    
    override func viewDidLoad() {
        mapView.delegate = self
        prepareUI()
        FlickrClient.searchPhotos(completion: handlePhotosSearchResponse(photosSearchResponse:error:))
    }
    
    func prepareUI() {
        downloadedImageCounter = 0
        numberImages = 0
        newCollectionButton.isEnabled = false
        mapView.addAnnotation(annotation)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
    }
    
    // MARK: -Completion Handlers
    func handlePhotosSearchResponse(photosSearchResponse: PhotosSearchResponse?, error: Error?) {
        print("photos: \(photosSearchResponse)")
        print("error \(error)")
        if photosSearchResponse != nil {
            numberImages = photosSearchResponse?.photos.photo.count ?? 0
            for photo in (photosSearchResponse?.photos.photo)! {
                FlickrClient.downloadPhoto(farmID: photo.farm, serverID: photo.server, photoID: photo.id, photoSecret: photo.secret, completion: handleDownloadPhotoResponse(image:))
            }
            
        }
    }
    
    func handleDownloadPhotoResponse(image: UIImage?) {
        downloadedImageCounter += 1
        DispatchQueue.main.async {
            self.imageView.image = image
        }
        manageNewCollectionButtonState()
    }
    
    func manageNewCollectionButtonState() {
        if downloadedImageCounter == numberImages {
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = true
            }
        }
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
