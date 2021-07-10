//
//  Vector.swift
//  Boids
//
//  Created by Eric Groom on 7/10/21.
//

import Foundation

struct Vec2 {
    var x: Double
    var y: Double
    
    var magnitude: Double {
        sqrt(x + y)
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
}
