//
//  MKPointAnnotation-ObservableObject.swift
//  BucketList
//
//  Created by Mac Van Anh on 5/19/20.
//  Copyright © 2020 Mac Van Anh. All rights reserved.
//

import Foundation
import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            self.title ?? "Unknown value"
        }
        
        set {
            title = newValue
        }
    }
    
    public var wrappedSubtitle: String {
        get {
            self.subtitle ?? "Unknown value"
        }
        
        set {
            subtitle = newValue
        }
    }
}
