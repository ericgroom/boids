//
//  BoidsCanvas.swift
//  Boids
//
//  Created by Eric Groom on 7/10/21.
//

import SwiftUI

struct BoidsCanvas: View {
    
    @StateObject var flock = FlockWrapper()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: false) { context, size in
                let now = timeline.date
                flock.update(time: now, size: size)
                
                flock.boids.forEach { boid in
                    let boidContext = context
                    let rect = viewRect(for: boid)
                    var color = Color.white
                    if boid.showAsRed {
                        color = .red
                    } else if boid.showAsBlue {
                        color = .blue
                    }
                    boidContext.fill(BoidShape().rotation(Angle(radians: boid.velocity.direction + Double.pi/2)).path(in: rect), with: .color(color))
                }
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color.gray)
        }
    }
    
    func viewRect(for boid: Boid) -> CGRect {
        let boidSize = CGSize(width: 12, height: 20)
        let adjustedOrigin = CGPoint(x: boid.position.x + boidSize.width / 2, y: boid.position.y)
        return CGRect(origin: adjustedOrigin, size: boidSize)
    }
}
