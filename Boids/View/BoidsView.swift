//
//  BoidsView.swift
//  Boids
//
//  Created by Eric Groom on 7/11/21.
//

import SwiftUI

struct BoidsView: View {
    @State var northernForceEnabled = false
    
    var body: some View {
        ZStack {
            BoidsCanvas(seekNorthEnabled: northernForceEnabled)
            VStack {
                Spacer()
                Picker("North Selection", selection: $northernForceEnabled) {
                    Text("Seek North").tag(true)
                    Text("Standard").tag(false)
                }
                .pickerStyle(.segmented)
            }
            .frame(maxWidth: 400)
            .padding()
        }
    }
}

struct BoidsView_Previews: PreviewProvider {
    static var previews: some View {
        BoidsView()
    }
}
