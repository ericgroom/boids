//
//  SpacialHash.swift
//  Boids
//
//  Created by Eric Groom on 7/12/21.
//

import Foundation
import SwiftUI

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
