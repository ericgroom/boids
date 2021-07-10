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
    
    typealias Context = (lastUpdate: Date, size: CGSize)
    private var context: Context?
    
    var visionRadius = 40.0
    
    mutating func update(time: Date, size: CGSize) {
        let shouldInitialize = self.context == nil
        let context = (lastUpdate: time, size: size)
        self.context = context
        if shouldInitialize {
            initialize(with: context)
        }
    }
    
    mutating private func initialize(with context: Context) {
        let boidCount = 30
        let xs = 0.0...(Double(context.size.width))
        let ys = 0.0...(Double(context.size.height))
        self.boids = (0..<boidCount).map { _ in
            Boid(position: .init(x: .random(in: xs), y: .random(in: ys)), velocity: .zero, acceleration: .zero)
        }
    }
}
