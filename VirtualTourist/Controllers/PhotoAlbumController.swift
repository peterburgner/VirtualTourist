//
//  PhotoAlbumController.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/8/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumController: UIViewController, UICollectionViewDataSource {
    
    // MARK: - Variables
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewFlowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var deleteButton: UIBarButtonItem!
    
    var dataController:DataController!
    var fetchedResultsController:NSFetchedResultsController<DownloadedPhoto>!
    
    var pin: Pin!
    var photosSearchResponse:PhotosSearchResponse!
    var numberOfDownloadedPhotos: Int { return fetchedResultsController.fetchedObjects?.count ?? 0}
    var numberOfPhotosToDownload = 0
    var page = 1
    var photosToDelete: [IndexPath] = []
    var hasFinishedDownloading = false
    var hasFetched: Bool { return fetchedResultsController.fetchedObjects?.count ?? 0 > 0}
    
    var insertedIndexPaths = [IndexPath]()
    var deletedIndexPaths = [IndexPath]()
    var updatedIndexPaths = [IndexPath]()
    
    let sectionInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    let photosPerRow: CGFloat = 3
    
    // MARK: -View Functions
    override func viewDidLoad() {
        mapView.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        prepareUI()
        resetUI()
        setupFetchedResultsController()
        if numberOfDownloadedPhotos == 0 {
            gettingPhotosToDownload = true
            FlickrClient.searchPhotos(coordinate: pin.coordinate, page: page, completion: handlePhotosSearchResponse(photosSearchResponse:error:))
        } else {
            gettingPhotosToDownload = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        prepareUI()
        resetUI()
    }
    
    func prepareUI() {
        collectionView.allowsMultipleSelection=true
        mapView.addAnnotation(pin)
        mapView.isScrollEnabled = false
        mapView.isZoomEnabled = false
        mapView.region = MKCoordinateRegion(center: pin.coordinate, latitudinalMeters: 100000, longitudinalMeters: 100000)
        deleteButton.isEnabled = false
    }
    
    func resetUI() {
        numberOfPhotosToDownload = 0
        photosToDelete = []
        setupFetchedResultsController()
        newCollectionButton.isEnabled = false
        deleteButton.isEnabled = false
        gettingPhotosToDownload = false
        downloadingPhotos = false
        hasFinishedDownloading = false
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<DownloadedPhoto> = DownloadedPhoto.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pin)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    // MARK: -IBActions
    @IBAction func createNewCollection(_ sender: Any) {
        resetUI()
        page += 1
        FlickrClient.searchPhotos(coordinate: pin.coordinate, page: page, completion: handlePhotosSearchResponse(photosSearchResponse:error:))
    }
    
    @IBAction func deletePhotos(_ sender: Any) {
        
        print("Begin deletion")
        print("Images to delete: \(photosToDelete)")
        print("Downloaded images: \(numberOfDownloadedPhotos)")
        
        for indexPath in photosToDelete {
            let noteToDelete = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(noteToDelete)
            try? dataController.viewContext.save()
            numberOfPhotosToDownload = numberOfPhotosToDownload - 1
        }
        
        photosToDelete = []
        collectionView.reloadData()
        
    }
    
    // MARK: -Photo Download Completion Handlers
    func handlePhotosSearchResponse(photosSearchResponse: PhotosSearchResponse?, error: Error?) {
        print("photos: \(photosSearchResponse)")
        print("error \(error)")
        if photosSearchResponse != nil {
            print("Display collection view with placeholders")
            self.photosSearchResponse = photosSearchResponse
            numberOfPhotosToDownload = photosSearchResponse?.photos.photo.count ?? 0
            print("Begin download of photos")
            gettingPhotosToDownload = false
            downloadingPhotos = true
            if numberOfPhotosToDownload > 0 {
                for photo in (photosSearchResponse?.photos.photo)! {
                    FlickrClient.downloadPhoto(farmID: photo.farm, serverID: photo.server, photoID: photo.id, photoSecret: photo.secret, completion: handleDownloadPhotoResponse(imageData:))
                }
            } else {
                hasFinishedDownloading = true
                collectionView.reloadData()
            }
        }
    }
    
    func handleDownloadPhotoResponse(imageData: Data?) {
        
        let photo = DownloadedPhoto(context: dataController.viewContext)
        photo.image = imageData
        photo.pin = pin
        try? dataController.viewContext.save()
        if numberOfDownloadedPhotos == numberOfPhotosToDownload {
            DispatchQueue.main.async {
                self.newCollectionButton.isEnabled = true
            }
            print("Download is complete")
            downloadingPhotos = false
            hasFinishedDownloading = true
        }
    }
}

// MARK: -Collection View Delegate
extension PhotoAlbumController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if hasFetched {
            // not all images persisted
            if downloadingPhotos {
                return numberOfPhotosToDownload
            } else {
                // all images already persisted
                return fetchedResultsController.fetchedObjects!.count
            }
        } else {
            // nothing fetched yet
            
            if hasFinishedDownloading {
                collectionView.setBackgroundMessage("No photos available")
            }
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.imageView.alpha = 1
        cell.backgroundColor = .darkGray
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 4
        // avoid displaying wrong image while scrolling and delete existing photos when new collection has not yet been downloaded
        cell.imageView.image = nil
        
        // set downloaded photos
        if numberOfDownloadedPhotos > indexPath.row {
            cell.imageView.image = UIImage(data: fetchedResultsController.object(at: indexPath).image!)
        }
        // Cell was selected for deletion
        if photosToDelete.contains(indexPath) {
            cell.imageView.alpha = 0.3
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Photo \(indexPath.row) marked for deletion")
        
        photosToDelete.append(indexPath)
        deleteButton.isEnabled = true
        
        collectionView.reloadItems(at: [indexPath])
    }
}

// MARK: - FetchedResultsControllerDelegate
extension PhotoAlbumController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?) {
        
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        default:
            print("\(type) operation: Should not have occured!")
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
}

// MARK: - MapViewDelegate
extension PhotoAlbumController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
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

// MARK: -ImageView extension
extension UIImageView {
    func setImageColor(color: UIColor) {
        let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
