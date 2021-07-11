//
//  Flock.swift
//  Boids
//
//  Created by Eric Groom on 7/10/21.
//

import SwiftUI

@dynamicMemberLookup
class FlockWrapper: ObservableObject {
    private var flock: Flock
    
    init() {
        self.flock = Flock()
    }
    
    func update(time: Date, size: CGSize) {
        flock.update(time: time, size: size)
    }
    
    subscript<T>(dynamicMember keyPath: KeyPath<Flock, T>) -> T {
        flock[keyPath: keyPath]
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<Flock, T>) -> T {
        get { flock[keyPath: keyPath] }
        set { flock[keyPath: keyPath] = newValue }
    }
}

struct Flock {
    var boids: [Boid] = []
    
    typealias Context = (t: Date, size: CGSize)
    private var context: Context?
    
    var visionRadius = 200.0
    var maxSpeed = 500.0
    var maxForce = 20.0
    
    mutating func update(time: Date, size: CGSize) {
        let context = (t: time, size: size)
        if let previousContext = self.context {
            let dt = context.t.timeIntervalSinceReferenceDate - previousContext.t.timeIntervalSinceReferenceDate
            physics(dt: dt, size: context.size)
        } else {
            initialize(with: context)
        }
        self.context = context
    }
    
    mutating private func initialize(with context: Context) {
        let boidCount = 30
        let xs = 0.0...(Double(context.size.width))
        let ys = 0.0...(Double(context.size.height))
        self.boids = (0..<boidCount).map { _ in

            let pi = Vec2(x: .random(in: xs), y: .random(in: ys))
            // mag = sqrt(x^2 + y^2)
            // mag^2 = x^2 + y^2
            // y^2 = mag^2 - x^2
            // y = sqrt(mag^2 - x^2)
            // assuming y = 0
            // mag = sqrt(x^2 + 0)
            // mag^2 = x^2
            // x = mag
            let speed = maxSpeed / 2
            let vxi = Double.random(in: 0...(speed))
            let vyi = sqrt(speed * speed - vxi * vxi)
            let vi = Vec2(x: vxi, y: vyi)
            return Boid(position: pi, velocity: vi, acceleration: .zero)
        }
        
        boids[0].showAsRed = true
    }
    
    typealias Force = Vec2
    typealias ForceGenerator = (Boid, [Boid]) -> Force
    
    mutating private func physics(dt: TimeInterval, size: CGSize) {
        let snapshot = boids
        let config = ForceConfiguration.default
        
        // reset accelleration
        boids = boids.map { boid in
            var boid = boid
            boid.acceleration = .zero
            return boid
        }
        
        // alignment
        boids = boids.map { boid in
            var boid = boid
            var force = alignmentForceGenerator(actOn: boid, boids: snapshot, configuration: config)
            force.limit(magnitude: maxForce)
            boid.acceleration += force
            return boid
        }
        
        // cohesion
        boids = boids.map { boid in
            var boid = boid
            var force = cohesionForceGenerator(actOn: boid, boids: snapshot, configuration: config)
            force.limit(magnitude: maxForce)
            boid.acceleration += force
            return boid
        }
        
        // separation
        boids = boids.map { boid in
            var boid = boid
            var force = separationForceGenerator(actOn: boid, boids: boids, configuration: config)
            force.limit(magnitude: maxForce)
            boid.acceleration += force
            return boid
        }
        
        // stay on screen
        boids = boids.map { boid in
            var boid = boid
            if boid.position.x > size.width {
                boid.position.x = 0
            } else if boid.position.x < 0 {
                boid.position.x = size.width
            }
            
            if boid.position.y > size.height {
                boid.position.y = 0
            } else if boid.position.y < 0 {
                boid.position.y = size.height
            }
            return boid
        }
        
        // position
        boids = boids.map { boid in
            var boid = boid
            boid.velocity += (boid.acceleration)
            boid.velocity.limit(magnitude: maxSpeed)
            boid.position += (boid.velocity * dt)
            return boid
        }
        
        // color
        let target = boids.first(where: { $0.showAsRed })
        boids = boids.map { boid in
            var boid = boid
            boid.showAsBlue = boid.position.distance(to: target!.position) < visionRadius
            return boid
        }
    }
}

struct ForceConfiguration {
    let visionRadius: Double
    let maxSpeed: Double
    
    static let `default` = ForceConfiguration(visionRadius: 200.0, maxSpeed: 500.0)
}

func alignmentForceGenerator(actOn boid: Boid, boids: [Boid], configuration: ForceConfiguration) -> Vec2 {
    var avgVelocity = Vec2.zero
    var count = 0
    for other in boids where other != boid && boid.position.distance(to: other.position) < configuration.visionRadius { // potential bug, need identity
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

func cohesionForceGenerator(actOn boid: Boid, boids: [Boid], configuration: ForceConfiguration) -> Vec2 {
    var avgPosition = Vec2.zero
    var count = 0
    for other in boids where other != boid && boid.position.distance(to: other.position) < configuration.visionRadius { // potential bug, need identity
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

func separationForceGenerator(actOn boid: Boid, boids: [Boid], configuration: ForceConfiguration) -> Vec2 {
    var steering = Vec2.zero
    var count = 0
    for other in boids where other != boid { // potential bug, need identity
        let distance = boid.position.distance(to: other.position)
        guard distance < configuration.visionRadius else { continue }
        
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
