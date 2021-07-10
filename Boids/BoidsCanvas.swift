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
            Canvas(opaque: true, colorMode: .linear, rendersAsynchronously: true) { context, size in
                let now = timeline.date
                flock.update(time: now, size: size)
                
                flock.boids.forEach { boid in
                    let boidContext = context
                    let rect = viewRect(for: boid)
                    boidContext.fill(Ellipse().path(in: rect), with: .color(.white))
                }
            }
            .edgesIgnoringSafeArea(.all)
            .background(Color.gray)
        }
    }
    
    func viewRect(for boid: Boid) -> CGRect {
        let boidSize = CGSize(width: 10, height: 10)
        let adjustedOrigin = CGPoint(x: boid.position.x + boidSize.width / 2, y: boid.position.y + boidSize.height / 2)
        return CGRect(origin: adjustedOrigin, size: boidSize)
    }
}
