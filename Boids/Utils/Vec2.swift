//
//  Vector.swift
//  Boids
//
//  Created by Eric Groom on 7/10/21.
//

import Foundation

struct Vec2: Equatable, Hashable {
    var x: Double
    var y: Double
    
    var magnitude: Double {
        get {
            sqrt(x * x + y * y)
        }
        set {
            normalize()
            x *= newValue
            y *= newValue
        }
    }
    
    /*
     Uses atan2 so the return value is within [-𝜋, 𝜋]
     */
    var direction: Double {
        atan2(y, x)
    }
    
    mutating func limit(magnitude: Double) {
        guard self.magnitude > magnitude else { return }
        self.magnitude = magnitude
    }
    
    mutating func lowerBound(magnitude: Double) {
        guard self.magnitude < magnitude else { return }
        self.magnitude = magnitude
    }
    
    func distance(to other: Vec2) -> Double {
        sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y))
    }
    
    mutating func normalize() {
        let magnitude = self.magnitude
        if magnitude != 0 {
            x /= magnitude
            y /= magnitude
        } else {
            x = 0
            y = 0
        }
    }
    
    var normalized: Vec2 {
        var copy = self
        copy.normalize()
        return copy
    }
    
    static let zero = Vec2(x: 0, y: 0)
    
    static func +(_ lhs: Self, _ rhs: Self) -> Self {
        Vec2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func +=( _ lhs: inout Self, _ rhs: Self) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    static func -(_ lhs: Self, _ rhs: Self) -> Self {
        Vec2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func -=( _ lhs: inout Self, _ rhs: Self) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    
    static func *(_ lhs: Self, _ rhs: Double) -> Self {
        Vec2(x: lhs.x * rhs, y: lhs.y * rhs)
    }
    
    static func *=(_ lhs: inout Self, _ rhs: Double) {
        lhs.x *= rhs
        lhs.y *= rhs
    }
    
    static func /(_ lhs: Self, _ rhs: Double) -> Self {
        Vec2(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    static func /=(_ lhs: inout Self, _ rhs: Double) {
        lhs.x /= rhs
        lhs.y /= rhs
    }
}
