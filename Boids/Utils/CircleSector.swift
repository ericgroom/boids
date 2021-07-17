//
//  CircleSector.swift
//  CircleSector
//
//  Created by Eric Groom on 7/15/21.
//

import Foundation

typealias Radians = Double

struct CircleSector {
    let center: Vec2
    let heading: Radians
    let width: Radians
    let radius: Double
    
    func contains(_ point: Vec2) -> Bool {
        guard center.distance(to: point) <= radius else { return false }
        
        let normalizedPoint = (point - center)
        let unnormalizedPointAngle = normalizedPoint.direction
        let pointAngle = unnormalizedPointAngle > 0 ? unnormalizedPointAngle : unnormalizedPointAngle + Double.pi*2
        
        // https://stackoverflow.com/a/38515984/6335864
        let dot = cos(heading)*cos(pointAngle) + sin(heading)*sin(pointAngle)
        let angle = acos(dot)
        
        return angle <= (width/2)
    }
}
