//
//  Pin+Extension.swift
//  VirtualTourist
//
//  Created by Peter Burgner on 10/15/19.
//  Copyright © 2019 Peter Burgner. All rights reserved.
//

import MapKit


extension Pin:MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude as Double, longitude: longitude as Double)
    }
}
