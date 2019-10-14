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
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var photosSearchResponse:PhotosSearchResponse!
    var downloadedPhotos = [UIImage]()
    var numberOfDownloadedPhotos: Int { return downloadedPhotos.count }
    var numberOfPhotosToDownload = 0
    var page = 1
    var photosToDelete: [Int] = []
    
    let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    let photosPerRow: CGFloat = 3
    
    var annotation:MKAnnotation!
    
    // MARK: -View Functions
    override func viewDidLoad() {
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        prepareUI()
        resetUI()
        FlickrClient.searchPhotos(coordinate: annotation.coordinate, page: page, completion: handlePhotosSearchResponse(photosSearchResponse:error:))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareUI()
        resetUI()
    }
    
    func prepareUI() {
        collectionView.allowsMultipleSelection=true
        mapView.addAnnotation(annotation)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
        deleteButton.isEnabled = false
    }
        
    func resetUI() {
        numberOfPhotosToDownload = 0
        photosToDelete = []
        downloadedPhotos = []
        newCollectionButton.isEnabled = false
        deleteButton.isEnabled = false
    }
    
    // MARK: -IBActions
    @IBAction func createNewCollection(_ sender: Any) {
        resetUI()
        page += 1
        FlickrClient.searchPhotos(coordinate: annotation.coordinate, page: page, completion: handlePhotosSearchResponse(photosSearchResponse:error:))
    }
    
    @IBAction func deletePhotos(_ sender: Any) {
        
        print("Begin deletion")
        print("Images to delete: \(photosToDelete)")
        print("Downloaded images: \(numberOfDownloadedPhotos)")
        
        for element in photosToDelete {
            downloadedPhotos.remove(at: element)
            numberOfPhotosToDownload = numberOfPhotosToDownload - 1
        }
        
        photosToDelete = []
        collectionView.reloadData()

    }
    
    // MARK: -Completion Handlers
    func handlePhotosSearchResponse(photosSearchResponse: PhotosSearchResponse?, error: Error?) {
        print("photos: \(photosSearchResponse)")
        print("error \(error)")
        if photosSearchResponse != nil {
            print("Display collection view with placeholders")
            self.photosSearchResponse = photosSearchResponse
            numberOfPhotosToDownload = photosSearchResponse?.photos.photo.count ?? 0
            collectionView.reloadData()
            print("Begin download of photos")
            for photo in (photosSearchResponse?.photos.photo)! {
                FlickrClient.downloadPhoto(farmID: photo.farm, serverID: photo.server, photoID: photo.id, photoSecret: photo.secret, completion: handleDownloadPhotoResponse(image:))
            }
        }
    }
    
    func handleDownloadPhotoResponse(image: UIImage?) {
        downloadedPhotos.append(image!)
        updateUI()
    }
    
    func updateUI() {
        
        // Reload collection view items
        let indexPath = IndexPath(row: numberOfDownloadedPhotos - 1, section: 0)
        DispatchQueue.main.async {
            print("Reloading collection view item at \(indexPath)")
            self.collectionView.reloadItems(at: [indexPath])
        }
        
        // Enable new collection button if download complete
        if numberOfDownloadedPhotos == numberOfPhotosToDownload {
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = true
            }
            print("Download is complete")
        }
    }
    
        // MARK: -Collection View Delegate
        
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if photosSearchResponse == nil {
            collectionView.setBackgroundMessage("Downloading photos from Flickr")
            return 0
        }
        if numberOfPhotosToDownload == 0 && page <= 1 {
            collectionView.setBackgroundMessage("No photos on Flickr for this location")
            return 0
        }
        if numberOfPhotosToDownload == 0 && page > 1 {
            collectionView.setBackgroundMessage("No additional photos on Flickr")
            return 0
        }
        else {
            collectionView.backgroundView = nil
            print("Collection view set up for \(numberOfPhotosToDownload) photos")
            return numberOfPhotosToDownload
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.imageView.alpha = 1
        cell.backgroundColor = .darkGray
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 4
        
        // set downloaded photos
        if downloadedPhotos.count > indexPath.row {
            cell.imageView.image = downloadedPhotos[indexPath.row]
        }
        // delete existing photos when new collection has not yet been downloaded
        if numberOfDownloadedPhotos == 0 {
            cell.imageView.image = nil
        }
        // Cell was selected for deletion
        if photosToDelete.contains(indexPath.row) {
            cell.imageView.alpha = 0.3
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Photo \(indexPath.row) marked for deletion")
        
        photosToDelete.append(indexPath.row)
        deleteButton.isEnabled = true
        
        collectionView.reloadItems(at: [indexPath])
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

extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
