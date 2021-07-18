//
//  BoidsCanvas.swift
//  Boids
//
//  Created by Eric Groom on 7/10/21.
//

import SwiftUI

struct BoidsCanvas: View {
    
    var seekNorthEnabled: Bool
    var displayVision: Bool = false
    @StateObject private var flock = FlockWrapper()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: false) { context, size in
                let now = timeline.date
                flock.update(time: now, size: size, northernForceEnabled: seekNorthEnabled)
                let fullCanvas = CGRect(origin: .zero, size: size)
                
                context.fill(Rectangle().path(in: fullCanvas), with: .color(background))
                flock.boids.forEach { boid in
                    let boidContext = context
                    let rect = viewRect(for: boid)
                    let color = boid.color
                    boidContext.fill(BoidShape().rotation(Angle(radians: boid.velocity.direction + Double.pi/2), anchor: .top).path(in: rect), with: .color(color))
                    if displayVision {
                        boidContext.stroke(CircleSectorShape(sector: boid.vision).path(in: fullCanvas), with: .color(Color(.sRGB, white: 1.0, opacity: 0.1)))
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func viewRect(for boid: Boid) -> CGRect {
        let boidSize = CGSize(width: 12, height: 20)
        let adjustedOrigin = CGPoint(x: boid.position.x - (boidSize.width/2), y: boid.position.y)
        return CGRect(origin: adjustedOrigin, size: boidSize)
    }
    
    var background: Color {
        Color("Background")
    }
}
