//
//  BoidsCanvas.swift
//  Boids
//
//  Created by Eric Groom on 7/10/21.
//

import SwiftUI

struct BoidsCanvas: View {
    
    var seekNorthEnabled: Bool
    @StateObject private var flock = FlockWrapper()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: false) { context, size in
                let now = timeline.date
                flock.update(time: now, size: size, northernForceEnabled: seekNorthEnabled)
                
                context.fill(Rectangle().path(in: CGRect(origin: .zero, size: size)), with: .color(background))
                flock.boids.forEach { boid in
                    let boidContext = context
                    let rect = viewRect(for: boid)
                    let color = boid.color
                    boidContext.fill(BoidShape().rotation(Angle(radians: boid.velocity.direction + Double.pi/2)).path(in: rect), with: .color(color))
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    
    func viewRect(for boid: Boid) -> CGRect {
        let boidSize = CGSize(width: 12, height: 20)
        let adjustedOrigin = CGPoint(x: boid.position.x + boidSize.width / 2, y: boid.position.y)
        return CGRect(origin: adjustedOrigin, size: boidSize)
    }
    
    var background: Color {
        Color("Background")
    }
}
