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
    
    var visionRadius = 40.0
    
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
            // mag = sqrt(x + y)
            // mag^2 = x + y
            // y = mag^2 - x
            // assuming y = 0
            // mag = sqrt(x + 0)
            // mag^2 = x
            let speed = 10.0
            let vxi = Double.random(in: 0...(speed * speed))
            let vyi = speed * speed - vxi
            let vi = Vec2(x: vxi, y: vyi)
            return Boid(position: pi, velocity: vi, acceleration: .zero)
        }
    }
    
    mutating private func physics(dt: TimeInterval, size: CGSize) {
        // velocity
        boids = boids.map { boid in
            var boid = boid
            boid.position += (boid.velocity * dt)
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
    }
}
