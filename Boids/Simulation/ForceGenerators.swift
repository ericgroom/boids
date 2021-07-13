//
//  ForceGenerators.swift
//  Boids
//
//  Created by Eric Groom on 7/12/21.
//

import Foundation

typealias Force = Vec2
typealias ForceGenerator = (Boid, SpacialHash<Boid>, ForceConfiguration) -> Force

struct ForceConfiguration {
    let visionRadius: Double
    let maxSpeed: Double
    
    static let `default` = ForceConfiguration(visionRadius: 200.0, maxSpeed: 300.0)
}

func alignmentForceGenerator(actOn boid: Boid, boids: SpacialHash<Boid>, configuration: ForceConfiguration) -> Force {
    var avgVelocity = Vec2.zero
    var count = 0
    for other in boids.query(within: configuration.visionRadius, of: boid.position) where other != boid { // potential bug, need identity
        avgVelocity += other.velocity
        count += 1
    }
    
    var steering = avgVelocity
    if count > 0 {
        steering /= Double(count)
        steering.magnitude = configuration.maxSpeed
        steering -= boid.velocity
    }
    return steering
}

func cohesionForceGenerator(actOn boid: Boid, boids: SpacialHash<Boid>, configuration: ForceConfiguration) -> Force {
    var avgPosition = Vec2.zero
    var count = 0
    for other in boids.query(within: configuration.visionRadius, of: boid.position) where other != boid { // potential bug, need identity
        avgPosition += other.position
        count += 1
    }

    var steering = avgPosition
    if count > 0 {
        steering /= Double(count)
        steering -= boid.position
        steering.magnitude = configuration.maxSpeed
        steering -= boid.velocity
    }
    return steering
}

func separationForceGenerator(actOn boid: Boid, boids: SpacialHash<Boid>, configuration: ForceConfiguration) -> Force {
    var steering = Vec2.zero
    var count = 0
    for other in boids.query(within: configuration.visionRadius, of: boid.position) where other != boid { // potential bug, need identity
        let distance = boid.position.distance(to: other.position)
        guard distance < configuration.visionRadius else { fatalError() }
        
        var diff = boid.position - other.position
        if distance*distance != 0 {
            diff /= distance*distance
        }
        steering += diff
        count += 1
    }

    if count > 0 {
        steering /= Double(count)
        steering.magnitude = configuration.maxSpeed
        steering -= boid.velocity
    }
    return steering
}

func northForceGenerator(actOn boid: Boid, boids: SpacialHash<Boid>, configuration: ForceConfiguration) -> Force {
    var steering = Vec2.zero
    if let heading = Compass.shared.angle {
        var radiansHeading = heading * Double.pi / 180
        let phaseShift = -(Double.pi/2)
        radiansHeading += phaseShift
        // after phase shift, north is 0, pi/2 is east, pi is south, 3pi/2 is west
        // we want north is 0, pi/2 is west, pi is south, 3pi/2 is east.
        // so we just negate the x result to reflect across the y axis
        let x = -cos(radiansHeading)
        let y = sin(radiansHeading)
        steering = Vec2(x: x, y: y)
        steering.magnitude = configuration.maxSpeed
        steering -= boid.velocity
    }
    return steering
}
