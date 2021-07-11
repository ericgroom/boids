//
//  Vector.swift
//  Boids
//
//  Created by Eric Groom on 7/10/21.
//

import Foundation

struct Vec2: Equatable {
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
    
    mutating func limit(magnitude: Double) {
        guard self.magnitude > magnitude else { return }
        self.magnitude = magnitude
    }
    
    func distance(to other: Vec2) -> Double {
        sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y))
    }
    
    mutating func normalize() {
        let magnitude = self.magnitude
        x /= magnitude
        y /= magnitude
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
