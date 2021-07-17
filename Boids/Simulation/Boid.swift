//
//  Boid.swift
//  Boids
//
//  Created by Eric Groom on 7/10/21.
//

import Foundation
import SwiftUI

let boidColors = [
    Color("Blue"),
    Color("Cyan"),
    Color("Red"),
    Color("Yellow"),
    Color("Green"),
    Color("Magenta")
]

struct Boid: Equatable {
    var position: Vec2
    var velocity: Vec2
    var acceleration: Vec2
    var visionRadius: Double
    
    let color: Color = boidColors.randomElement()!
    
    var vision: CircleSector {
        CircleSector(center: position, heading: velocity.direction, width: .pi/3, radius: visionRadius)
    }
}
