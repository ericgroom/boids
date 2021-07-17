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
        let centerAngle = sector.heading < 0 ? sector.heading + Double.pi * 2 : sector.heading
        let startAngle = centerAngle - sector.width
        let endAngle = centerAngle + sector.width
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
    }
}
