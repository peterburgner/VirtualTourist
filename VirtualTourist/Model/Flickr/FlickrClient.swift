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
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=6a31cb5b682400eaa885b79668f45dd1&lat=31&lon=-113&format=json&nojsoncallback=1"
        static let apiKey = "&api_key=" + Auth.apiKey
        static let format = "&format=json&nojsoncallback=1"
        
        case search(String, String)
        
        var stringValue: String {
            switch self {
            case .search(let lat, let long): return Endpoints.base + "?method=flickr.photos.search" + Endpoints.apiKey + "&lat=" + lat + "&long=" + long + Endpoints.format
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    

    
    
    
}
