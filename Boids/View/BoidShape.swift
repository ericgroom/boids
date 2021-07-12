//
//  BoidShape.swift
//  Boids
//
//  Created by Eric Groom on 7/11/21.
//

import SwiftUI

struct BoidShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let top = CGPoint(x: rect.midX, y: rect.minY)
        let left = CGPoint(x: rect.minX, y: rect.maxY)
        let right = CGPoint(x: rect.maxX, y: rect.maxY)
        
        path.move(to: top)
        path.addLine(to: left)
        let curveOffset = rect.height*0.2
        path.addQuadCurve(to: right, control: CGPoint(x: rect.midX, y: rect.maxY-curveOffset))
        path.addLine(to: top)
        return path
    }
    
}

struct BoidShape_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            BoidShape()
                .stroke(.blue, lineWidth: 2.0)
                .frame(width: 150, height: 200, alignment: .center)
                .background(Rectangle().stroke(.red))
                .padding()
            BoidShape()
                .stroke(.blue, lineWidth: 2.0)
                .frame(width: 150, height: 200, alignment: .center)
                .background(Rectangle().stroke(.red))
                .padding()
        }
        .previewLayout(.sizeThatFits)
    }
}
