//
//  ContentView.swift
//  A2MapKit
//
//  Created by Default User on 10/27/23.
//

import SwiftUI
import MapKit



struct ContentView: View {
    
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    
    @State private var userLocation: MapUserTrackingMode = .follow
    
    var body: some View {
        NavigationStack {
            Text("Map Navigation in SwiftUI")
                .padding(50)
            NavigationLink(destination: MapView()){
                Text("Go to Map Navigation")
            }.padding(50)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
