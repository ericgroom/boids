//
//  CircleSectorShape.swift
//  CircleSectorShape
//
//  Created by Eric Groom on 7/15/21.
//

import Foundation
import SwiftUI

struct CircleSectorShape: Shape {
    let sector: CircleSector
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: sector.center.x, y: sector.center.y))
        let heading = sector.heading < 0 ? sector.heading + Double.pi * 2 : sector.heading
        let startAngle = heading - (sector.width / 2)
        let endAngle = heading + (sector.width / 2)
        let startPoint = Vec2(x: cos(startAngle), y: sin(startAngle)) * sector.radius + sector.center
        let endPoint = Vec2(x: cos(endAngle), y: sin(endAngle)) * sector.radius + sector.center
        path.addLine(to: CGPoint(x: startPoint.x, y: startPoint.y))
        path.addArc(center: CGPoint(x: sector.center.x, y: sector.center.y), radius: sector.radius, startAngle: .radians(startAngle), endAngle: .radians(endAngle), clockwise: false)
        path.addLine(to: CGPoint(x: sector.center.x, y: sector.center.y))
        return path
    }
}

struct CircleSectorShape_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // basic
            GeometryReader { proxy in
                let frame = proxy.frame(in: .global)
                let middle = Vec2(x: frame.midX, y: frame.midY)
                ZStack {
                    CircleSectorShape(sector: CircleSector(center: middle, heading: .pi/4, width: .pi/8, radius: 200.0))
                        .stroke()
                    CircleSectorShape(sector: CircleSector(center: middle, heading: .pi/4 + .pi/2, width: .pi/8, radius: 200.0))
                        .stroke()
                    CircleSectorShape(sector: CircleSector(center: middle, heading: .pi/4 - .pi/2, width: .pi/8, radius: 200.0))
                        .stroke()
                    CircleSectorShape(sector: CircleSector(center: middle, heading: .pi/4 - .pi, width: .pi/8, radius: 200.0))
                        .stroke()
                }
            }
            
            // particle hit testing
            Canvas { context, size in
                let wholeCanvas = CGRect(origin: .zero, size: size)
                let particleCount = 1000
                let xs = 0.0..<Double(size.width)
                let ys = 0.0..<Double(size.height)
                func generatePoint() -> Vec2 {
                    Vec2(x: Double.random(in: xs), y: Double.random(in: ys))
                }
                let points = (0..<particleCount).map { _ in generatePoint() }
                
                let testSector = CircleSector(center: generatePoint(), heading: Double.random(in: 0..<(Double.pi * 2)), width: Double.random(in: (Double.pi/64)..<Double.pi), radius: Double.random(in: 10..<400))
                
                context.stroke(CircleSectorShape(sector: testSector).path(in: wholeCanvas), with: .color(.gray))
                for point in points {
                    let color: Color = testSector.contains(point) ? .green : .gray
                    context.fill(ParticleShape(position: point, radius: 2.0).path(in: wholeCanvas), with: .color(color))
                }
                
                context.draw(Text("Width: \(testSector.width), Heading: \(testSector.heading)"), at: CGPoint(x: size.width/2, y: size.height * 0.99))
            }
        }
    }
}
