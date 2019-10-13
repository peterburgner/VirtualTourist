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
    var downloadComplete = false
    
    var photosSearchResponse:PhotosSearchResponse!
    var downloadedPhotos = [UIImage]()
    var numberImages = 0
    var page = 1
    
    let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    let photosPerRow: CGFloat = 3
    
    var annotation:MKAnnotation!
    
    // MARK: -View Functions
    override func viewDidLoad() {
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        prepareMap()
        resetUI()
        FlickrClient.searchPhotos(coordinate: annotation.coordinate, page: page, completion: handlePhotosSearchResponse(photosSearchResponse:error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareMap()
        resetUI()
    }
    
    func prepareMap() {
        mapView.addAnnotation(annotation)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
    }
        
    func resetUI() {
        downloadedImageCounter = 0
        numberImages = 0
        downloadedPhotos = []
        newCollectionButton.isEnabled = false
    }
    
    // MARK: -Completion Handlers
    func handlePhotosSearchResponse(photosSearchResponse: PhotosSearchResponse?, error: Error?) {
        print("photos: \(photosSearchResponse)")
        print("error \(error)")
        if photosSearchResponse != nil {
            collectionView.reloadData()
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
        updateUI()
    }
    
    func updateUI() {
        if downloadedImageCounter == numberImages {
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = true
            }
            downloadComplete = true
        }
        let indexPath = IndexPath(item: downloadedImageCounter - 1, section: 0)
        DispatchQueue.main.async {
            self.collectionView.reloadItems(at: [indexPath])
        }
    }
    
    // MARK: -Collection View Delegate
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let photosSearchResponse = photosSearchResponse else {
            collectionView.setBackgroundMessage("Downloading photos from Flickr")
            return 0
        }
        if photosSearchResponse.photos.photo.count == 0 && page <= 1 {
            collectionView.setBackgroundMessage("No photos on Flickr for this location")
            return 0
        }
        if photosSearchResponse.photos.photo.count == 0 && page > 1 {
            collectionView.setBackgroundMessage("No additional photos on Flickr")
            return 0
        }
        else {
            collectionView.backgroundView = nil
            return photosSearchResponse.photos.photo.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.backgroundColor = .darkGray
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 4
        
        if downloadedPhotos.count > indexPath.row {
            cell.imageView.image = downloadedPhotos[indexPath.row]
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Item selected")
        // TODO: Add delete feature
    }
    
    // MARK: -IBActions
    @IBAction func createNewCollection(_ sender: Any) {
        resetUI()
        page += 1
        FlickrClient.searchPhotos(coordinate: annotation.coordinate, page: page, completion: handlePhotosSearchResponse(photosSearchResponse:error:))
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
    
}

// MARK: -Flow Layout Delegate
extension PhotoAlbumController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = (sectionInsets.left + sectionInsets.right) * (photosPerRow)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerPhoto = availableWidth / photosPerRow
        
        return CGSize(width: widthPerPhoto, height: widthPerPhoto)
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

// MARK: -UICollectionView extension
extension UICollectionView {

    func setBackgroundMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "Avenir-Light", size: 18)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel
    }
}
