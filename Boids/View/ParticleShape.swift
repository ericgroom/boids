//
//  ParticleShape.swift
//  ParticleShape
//
//  Created by Eric Groom on 7/17/21.
//

import SwiftUI

struct ParticleShape: Shape {
    let position: Vec2
    let radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: position.x, y: position.y)
        let origin = CGPoint(x: center.x - radius, y: center.y - radius)
        path.addEllipse(in: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2)))
        return path
    }
}

struct ParticleShape_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // scatter
            GeometryReader { proxy in
                let size = proxy.frame(in: .local).size
                let pointsToGenerate = 100
                let xs = 0.0..<Double(size.width)
                let ys = 0.0..<Double(size.height)
                let points = (0..<pointsToGenerate).map { _ in
                    Vec2(x: Double.random(in: xs), y: Double.random(in: ys))
                }
                ZStack {
                    ForEach(points, id: \.self) { point in
                        ParticleShape(position: point, radius: 6.0)
                            .fill(.green)
                    }
                }
            }
            // precision
            ZStack {
                Rectangle()
                    .fill(.green)
                    .frame(width: 100, height: 100, alignment: .center)
            }.overlay(
                GeometryReader { proxy in
                    let size = proxy.frame(in: .local).size
                    ParticleShape(position: Vec2(x: size.width/2, y: size.height/2), radius: 50.0)
                        .fill(.red)
                }
            )
        }
    }
}
