//
//  QuadTree.swift
//  Boids
//
//  Created by Eric Groom on 7/12/21.
//

import Foundation

struct QuadTree<Element> {
    let region: Region
    let capacity: Int
    let positionMap: KeyPath<Element, Vec2>
    private var contents: Contents
    
    init(region: Region, capacity: Int, positionMap: KeyPath<Element, Vec2>) {
        self.region = region
        self.capacity = capacity
        self.positionMap = positionMap
        self.contents = .undivided(elements: [])
    }
    
    init(region: Region, capacity: Int, elements: [Element], positionMap: KeyPath<Element, Vec2>) {
        self.init(region: region, capacity: capacity, positionMap: positionMap)
        
        for element in elements {
            insert(element)
        }
    }

    private enum Contents {
        case undivided(elements: [Element])
        indirect case divided(ne: QuadTree, nw: QuadTree, se: QuadTree, sw: QuadTree)
        
        var unsafeElements: [Element] {
            switch self {
            case .undivided(let elements):
                return elements
            case .divided:
                fatalError()
            }
        }
    }
    
    mutating func insert(_ element: Element) {
        let position = element[keyPath: positionMap]
        guard region.contains(position) else { return }
        
        switch contents {
        case .undivided(var elements):
            guard elements.count + 1 <= capacity else {
                subdivide(with: element)
                return
            }
            elements.append(element)
            self.contents = .undivided(elements: elements)
        case .divided(var ne, var nw, var se, var sw):
            ne.insert(element)
            nw.insert(element)
            se.insert(element)
            sw.insert(element)
            
            self.contents = .divided(ne: ne, nw: nw, se: se, sw: sw)
        }
    }
    
    func query(within radius: Double, of position: Vec2) -> [Element] {
        switch contents {
        case .undivided(let elements):
            return elements.filter { position.distance(to: $0[keyPath: positionMap]) <= radius }
        case .divided(let ne, let nw, let se, let sw):
            return ne.query(within: radius, of: position) + nw.query(within: radius, of: position) + se.query(within: radius, of: position) + sw.query(within: radius, of: position)
        }
    }
    
    mutating private func subdivide(with newElement: Element) {
        var elements = contents.unsafeElements
        elements.append(newElement)
        let subregionWidth = region.width / 2
        let subregionHeight = region.height / 2
        let nwRegion = Region(x: region.x, y: region.y, width: subregionWidth, height: subregionHeight)
        var nw = QuadTree(region: nwRegion, capacity: capacity, positionMap: positionMap)
        let neRegion = Region(x: region.x + subregionWidth, y: region.y, width: subregionWidth, height: subregionHeight)
        var ne = QuadTree(region: neRegion, capacity: capacity, positionMap: positionMap)
        let swRegion = Region(x: region.x, y: region.y + subregionHeight, width: subregionWidth, height: subregionHeight)
        var sw = QuadTree(region: swRegion, capacity: capacity, positionMap: positionMap)
        let seRegion = Region(x: region.x + subregionWidth, y: region.y + subregionHeight, width: subregionWidth, height: subregionHeight)
        var se = QuadTree(region: seRegion, capacity: capacity, positionMap: positionMap)
        for element in elements {
            nw.insert(element)
            ne.insert(element)
            sw.insert(element)
            se.insert(element)
        }
        self.contents = .divided(ne: ne, nw: nw, se: se, sw: sw)
    }
}
