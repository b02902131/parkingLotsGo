//
//  lotsAnnotation.swift
//  tryMapKit
//
//  Created by Bigyo on 11/12/2016.
//  Copyright © 2016 Bigyo. All rights reserved.
//

import UIKit
import MapKit

class LotsAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var image: UIImage?
    var lots_num: Int?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}
