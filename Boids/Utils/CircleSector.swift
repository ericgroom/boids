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
    
    // XCTAssertTrue failed - CircleSector(center: Boids.Vec2(x: 0.0, y: 0.0), heading: 3.9269908169872414, width: 0.39269908169872414, radius: 3.0) does not contain Vec2(x: -1.4142135623730954, y: -1.414213562373095)
    
    func contains(_ point: Vec2) -> Bool {
        guard center.distance(to: point) <= radius else { return false }
        
        let normalizedPoint = (point - center)
        let unnormalizedPointAngle = normalizedPoint.direction
        let pointAngle = unnormalizedPointAngle > 0 ? unnormalizedPointAngle : unnormalizedPointAngle + Double.pi*2
        
        let startAngle = heading - width/2
        let endAngle = heading + width/2
        
        return startAngle <= pointAngle &&  pointAngle <= endAngle
    }
}
