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

struct SpacialHash<Element> {
    private let cellSize: CGSize
    private var store: [Cell: [Element]]
    private let positionMap: KeyPath<Element, Vec2>
    
    private struct Cell: Hashable {
        let x: Int
        let y: Int
        
        init(x: Int, y: Int) {
            self.x = x
            self.y = y
        }
    }
    
    init(_ elements: [Element], positionMap: KeyPath<Element, Vec2>) {
        self.cellSize = .init(width: 20, height: 20)
        self.store = [:]
        self.positionMap = positionMap
        for element in elements {
            insert(element)
        }
    }
    
    private func cell(for position: Vec2) -> Cell {
        Cell(x: Int(position.x / cellSize.width), y: Int(position.y / cellSize.height))
    }
    
    mutating func insert(_ element: Element) {
        let position = element[keyPath: positionMap]
        let cell = cell(for: position)
        store[cell, default: []].append(element)
    }
    
    func neighbors(of position: Vec2, within radius: Double) -> Array<Element> {
        let minX = position.x - radius
        let minY = position.y - radius
        let maxX = position.x + radius
        let maxY = position.y + radius
        let xs = stride(from: minX, to: maxX, by: cellSize.width)
        let ys = stride(from: minY, to: maxY, by: cellSize.height)
        let cells = xs
            .flatMap { x in
                ys.map { y in
                    Vec2(x: x, y: y)
                }
            }
            .map { cell(for: $0) }
        
        let elements = cells
            .flatMap { store[$0, default: []] }
            .filter { other in
                let distanceToOther = position.distance(to: other[keyPath: positionMap])
                return distanceToOther < radius
            }
        
        return elements
    }
}

struct Flock {
    var boids: [Boid] = []
    
    typealias Context = (t: Date, size: CGSize)
    private var context: Context?
    
    var visionRadius = 200.0
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
            return Boid(position: pi, velocity: vi, acceleration: .zero)
        }
    }
    
    typealias Force = Vec2
    typealias ForceGenerator = (Boid, SpacialHash<Boid>, ForceConfiguration) -> Force
    
    mutating private func physics(dt: TimeInterval, size: CGSize) {
        let snapshot = SpacialHash(boids, positionMap: \.position)
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
            (northForceGenerator, northernForceEnabled ? 0.1 : 0.0),
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

struct ForceConfiguration {
    let visionRadius: Double
    let maxSpeed: Double
    
    static let `default` = ForceConfiguration(visionRadius: 200.0, maxSpeed: 300.0)
}

func alignmentForceGenerator(actOn boid: Boid, boids: SpacialHash<Boid>, configuration: ForceConfiguration) -> Vec2 {
    var avgVelocity = Vec2.zero
    var count = 0
    for other in boids.neighbors(of: boid.position, within: configuration.visionRadius) where other != boid { // potential bug, need identity
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

func cohesionForceGenerator(actOn boid: Boid, boids: SpacialHash<Boid>, configuration: ForceConfiguration) -> Vec2 {
    var avgPosition = Vec2.zero
    var count = 0
    for other in boids.neighbors(of: boid.position, within: configuration.visionRadius) where other != boid { // potential bug, need identity
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

func separationForceGenerator(actOn boid: Boid, boids: SpacialHash<Boid>, configuration: ForceConfiguration) -> Vec2 {
    var steering = Vec2.zero
    var count = 0
    for other in boids.neighbors(of: boid.position, within: configuration.visionRadius) where other != boid { // potential bug, need identity
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

func northForceGenerator(actOn boid: Boid, boids: SpacialHash<Boid>, configuration: ForceConfiguration) -> Vec2 {
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
