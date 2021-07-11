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
    
    mutating private func physics(dt: TimeInterval, size: CGSize) {
        let snapshot = boids
        
        // reset accelleration
        boids = boids.map { boid in
            var boid = boid
            boid.acceleration = .zero
            return boid
        }
        
        // cohesion
        boids = boids.map { boid in
            var boid = boid
            var avgPosition = Vec2.zero
            var count = 0
            for other in snapshot where other != boid && boid.position.distance(to: other.position) < visionRadius { // potential bug, need identity
                avgPosition += other.position
                count += 1
            }

            if count > 0 {
                avgPosition /= Double(count)
            }
            var steering = avgPosition - boid.position
            steering.magnitude = maxSpeed
            steering -= boid.velocity
            steering.limit(magnitude: maxForce)
            boid.acceleration += steering

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
