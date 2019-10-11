//
//  PhotosSearchResponse.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/10/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import Foundation

// MARK: - FlickrSearch
struct FlickrSearch: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages: Int
    let perpage: String
    let total: Int
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret: String
    let server: Int
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
