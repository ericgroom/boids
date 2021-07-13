//
//  Region.swift
//  Boids
//
//  Created by Eric Groom on 7/12/21.
//

import Foundation

struct Region: Equatable, Hashable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    
    func contains(_ other: Region) -> Bool {
        other.x >= self.x && other.y >= self.y && other.width <= self.width && other.height <= self.height
    }
    
    func contains(_ point: Vec2) -> Bool {
        point.x >= self.x && point.x <= self.x + self.width && point.y >= self.y && point.y <= self.y + self.height
    }
}
