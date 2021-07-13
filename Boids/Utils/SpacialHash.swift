//
//  SpacialHash.swift
//  Boids
//
//  Created by Eric Groom on 7/12/21.
//

import Foundation

// Not used, implementation is sound but dictionary lookups on `store` are **incredibly** slow for some reason. Like 80-90% of total execution time, QuadTree wins out even without COW
struct SpacialHash<Element> {
    private let cellSize: Size
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
    
    func query(region: Region) -> [Element] {
        let minX = region.x
        let minY = region.y
        let maxX = region.x + region.width
        let maxY = region.y + region.height
        let minCellX = Int(minX/cellSize.width)
        let maxCellX = Int(maxX/cellSize.width)
        let minCellY = Int(minY/cellSize.height)
        let maxCellY = Int(maxY/cellSize.height)
        var results = [Element]()
        for xCell in minCellX...maxCellX {
            for yCell in minCellY...maxCellY {
                let cell = Cell(x: xCell, y: yCell)
                let elements = store[cell, default: []]
                let regionMinX = Double(cell.x) * cellSize.width
                let regionMinY = Double(cell.y) * cellSize.height
                let cellRegion = Region(x: regionMinX, y: regionMinY, width: cellSize.width, height: cellSize.height)
                // check if cell region is within main region
                if region.contains(cellRegion) {
                    results.append(contentsOf: elements)
                } else {
                    for element in elements {
                        guard region.contains(element[keyPath: positionMap]) else { continue }
                        results.append(element)
                    }
                }
            }
        }
        return results
    }
    
    func query(within radius: Double, of position: Vec2) -> [Element] {
        let x = position.x - radius
        let y = position.y - radius
        let width = position.x + 2 * radius
        let height = position.y + 2 * radius
        let approximateRegion = Region(x: x, y: y, width: width, height: height)
        
        return query(region: approximateRegion)
            .filter { other in
                let otherPosition = other[keyPath: positionMap]
                return position.distance(to: otherPosition) <= radius
            }
    }
}
