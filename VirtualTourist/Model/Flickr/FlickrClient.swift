//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/10/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//


import Foundation
import MapKit

class FlickrClient {
    
    struct Auth {
        static var apiKey = "6a31cb5b682400eaa885b79668f45dd1"
        static var secret = "bb9d01474a59d97d"
    }
    
    enum Endpoints {
        static let base = "https://www.flickr.com/services/rest/"
        static let apiKey = "&api_key=" + Auth.apiKey
        static let format = "&format=json&nojsoncallback=1"
        
        case search(String, String)
        case photo(Int, Int, String, String)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let long): return Endpoints.base + "?method=flickr.photos.search" + Endpoints.apiKey + "&lat=" + lat + "&lon=" + long + Endpoints.format
            case .photo(let farmID, let serverID, let photoID, let photoSecret): return "https://farm\(farmID).staticflickr.com/\(serverID)/\(photoID)_\(photoSecret).jpg"
                // example: "https://farm8.staticflickr.com/7409/9256183076_faf2883a07.jpg"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    class func searchPhotos(completion: @escaping (PhotosSearchResponse?, Error?) -> Void ) {
        print("Execute photo search")
        let request = URLRequest(url: Endpoints.search("35.87724743459462", "-120.09037686776658").url)
        print(request)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            if error != nil {
                completion (nil, error)
                return
            }
            
            guard let httpStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                completion (nil, error)
                return
            }
            
            if httpStatusCode >= 200 && httpStatusCode < 300 {
                let decoder = JSONDecoder()
                
                guard let data = data else {
                    completion (nil, error)
                    return
                }
                
                do {
                    let photosSearchResponse = try decoder.decode(PhotosSearchResponse.self, from: data)
                    DispatchQueue.main.async {
                        completion(photosSearchResponse, nil)
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        completion(nil,error)
                    }
                    return
                }
            }
            else {
                // create custom error for all httpStatusCodes
                return completion (nil, NSError(domain:"", code:httpStatusCode, userInfo:nil))
            }
        }
        task.resume()
    }
    
}
