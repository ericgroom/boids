//
//  Compass.swift
//  Boids
//
//  Created by Eric Groom on 7/11/21.
//

import Foundation
import CoreLocation

class Compass: NSObject {
    static let shared = Compass()
    private let locationManager = CLLocationManager()
    private var heading: CLHeading?
    
    /**
     In degrees, North is 0, 90 is east, 180 is south, 270 is west
     */
    var angle: Double? {
        guard let trueHeading = heading?.magneticHeading else { return nil }
        guard trueHeading >= 0 else { return nil }
        return trueHeading
    }
    
    private override init() {
        super.init()
        locationManager.startUpdatingHeading()
        locationManager.delegate = self
    }
}

extension Compass: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading
    }
}
