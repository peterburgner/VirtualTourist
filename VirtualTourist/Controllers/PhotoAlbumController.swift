//
//  PhotoAlbumController.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/8/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
   
    // MARK: - Variables
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    var downloadedImageCounter = 0
    var numberImages = 0
    var downloadComplete = false
    var photosSearchResponse:PhotosSearchResponse!
    var downloadedPhotos = [UIImage]()
    let sectionInsets = UIEdgeInsets(top: 20.0 ,left: 20.0, bottom: 20.0, right: 20.0)
    let itemsPerRow: CGFloat = 3
    
    var annotation:MKAnnotation!
    
    override func viewDidLoad() {
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
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
            self.photosSearchResponse = photosSearchResponse
            numberImages = photosSearchResponse?.photos.photo.count ?? 0
            for photo in (photosSearchResponse?.photos.photo)! {
                FlickrClient.downloadPhoto(farmID: photo.farm, serverID: photo.server, photoID: photo.id, photoSecret: photo.secret, completion: handleDownloadPhotoResponse(image:))
            }
        }
    }
    
    func handleDownloadPhotoResponse(image: UIImage?) {
        downloadedImageCounter += 1
        downloadedPhotos.append(image!)
        manageNewCollectionButtonState()
    }
    
    func manageNewCollectionButtonState() {
        if downloadedImageCounter == numberImages {
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = true
                self.collectionView.reloadData()
            }
            downloadComplete = true
        }
    }
    
    // MARK: -Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item selected")
    }
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if downloadComplete {
            return photosSearchResponse.photos.photo.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.backgroundColor = .darkGray
        if downloadComplete == true {
            cell.imageView.image = downloadedPhotos[indexPath.row]
        }
        return cell
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

// MARK: -Collection View Flow Layout Delegate
extension PhotoAlbumController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}
