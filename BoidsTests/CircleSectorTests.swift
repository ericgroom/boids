//
//  CircleSectorTests.swift
//  CircleSectorTests
//
//  Created by Eric Groom on 7/15/21.
//

import XCTest
@testable import Boids

class CircleSectorTests: XCTestCase {
    
    func testTheHappiestOfPaths() {
        let point = Vec2(x: 0.5, y: 0.5)
        let sector = CircleSector(center: .zero, heading: .pi/4, width: .pi/8, radius: 1.0)
        
        XCTAssertTrue(sector.contains(point))
    }
    
    func testReturnsFalseForPointOutOfRange() {
        let range = 3.0
        let angle = Double.pi/3
        let inRangePoint = Vec2(x: cos(angle), y: sin(angle)) * (range - 1.0)
        let outOfRangePoint = Vec2(x: cos(angle), y: sin(angle)) * (range + 1.0)
        let sector = CircleSector(center: .zero, heading: angle, width: .pi/8, radius: range)
        
        XCTAssertTrue(sector.contains(inRangePoint))
        XCTAssertFalse(sector.contains(outOfRangePoint))
    }
    
    func testSectorsAreConsistent() {
        let angles = { () -> [Double] in
            let angle = Double.pi/4
            var result = [Double]()
            for multiple in 0..<4 {
                result.append((Double.pi/2 * Double(multiple)) + angle)
            }
            return result
        }()
        let unitPoints = angles.map { Vec2(x: cos($0), y: sin($0)) }
        let range = 3.0
        let sectors = angles.map { CircleSector(center: .zero, heading: $0, width: .pi/8, radius: range)}
        let shortLongPoints = unitPoints.map { ($0 * (range - 1.0), $0 * (range + 1.0 )) }
        for ((short, long), sector) in zip(shortLongPoints, sectors) {
            XCTAssertTrue(sector.contains(short), "\(sector) does not contain \(short)")
            XCTAssertFalse(sector.contains(long), "\(sector) contains \(long)")
        }
    }
    
    func testSectorsCanMiss() {
        let angles = { () -> [Double] in
            let angle = Double.pi/4
            var result = [Double]()
            for multiple in 0..<4 {
                result.append((Double.pi/2 * Double(multiple)) + angle)
            }
            return result
        }()
        let width = Double.pi/8
        let unitPoints = angles.map { Vec2(x: cos($0 + width + 0.01), y: sin($0 + width + 0.01)) }
        let range = 3.0
        let sectors = angles.map { CircleSector(center: .zero, heading: $0, width: width, radius: range)}
        let shortLongPoints = unitPoints.map { ($0 * (range - 1.0), $0 * (range + 1.0 )) }
        for ((short, long), sector) in zip(shortLongPoints, sectors) {
            XCTAssertFalse(sector.contains(short), "\(sector) does not contain \(short)")
            XCTAssertFalse(sector.contains(long), "\(sector) contains \(long)")
        }
    }
    
    func testOffCenter() {
        let sector = CircleSector(center: Vec2(x: 20, y: 50), heading: .pi/4, width: .pi/8, radius: 20.0)
        let containsPoint = Vec2(x: 21, y: 51)
        let doesntContainPoint = Vec2(x: 19, y: 50)
        XCTAssertTrue(sector.contains(containsPoint))
        XCTAssertFalse(sector.contains(doesntContainPoint))
    }
    
    func testAcrossZeroLine() {
        let sector = CircleSector(center: .zero, heading: 0, width: .pi, radius: 50.0)
        let south = Vec2(x: 20.0, y: -20.0)
        let north = Vec2(x: 20.0, y: 20.0)
        XCTAssertTrue(sector.contains(south))
        XCTAssertTrue(sector.contains(north))
    }
    
    func testAcrossPiLine() {
        let sector = CircleSector(center: .zero, heading: .pi, width: .pi, radius: 50.0)
        let south = Vec2(x: -20.0, y: -20.0)
        let north = Vec2(x: -20.0, y: 20.0)
        XCTAssertTrue(sector.contains(south))
        XCTAssertTrue(sector.contains(north))
    }

}
