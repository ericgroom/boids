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
    
    func update(time: Date, size: CGSize, northernForceEnabled: Bool) {
        flock.update(time: time, size: size, northernForceEnabled: northernForceEnabled)
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
    
    var visionRadius = 50.0
    var maxSpeed = 300.0
    var maxForce = 20.0
    var northernForceEnabled = false
    
    mutating func update(time: Date, size: CGSize, northernForceEnabled: Bool) {
        let context = (t: time, size: size)
        self.northernForceEnabled = northernForceEnabled
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
            let vxi = Double.random(in: (-speed)...(speed))
            let vyi = sqrt(speed * speed - vxi * vxi)
            let vi = Vec2(x: vxi, y: vyi)
            return Boid(position: pi, velocity: vi, acceleration: .zero, visionRadius: visionRadius)
        }
    }
    
    mutating private func physics(dt: TimeInterval, size: CGSize) {
        let snapshot = boids
        let config = ForceConfiguration.default
        
        // reset accelleration
        boids = boids.map { boid in
            var boid = boid
            boid.acceleration = .zero
            return boid
        }
        
        // alignment, cohesion, separation
        let forceGenerators: [(ForceGenerator, Double)] = [
            (alignmentForceGenerator, 0.25),
            (cohesionForceGenerator, 0.25),
            (separationForceGenerator, 0.25),
            (northForceGenerator, northernForceEnabled ? 0.05 : 0.0),
        ]
        boids = boids.map { boid in
            var boid = boid
            for (forceGenerator, importance) in forceGenerators {
                var force = forceGenerator(boid, snapshot, config)
                force.limit(magnitude: maxForce)
                force *= importance
                boid.acceleration += force
            }
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
    }
}
