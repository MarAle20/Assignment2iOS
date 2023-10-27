//
//  ContentView.swift
//  A2MapKit
//
//  Created by Default User on 10/27/23.
//

import SwiftUI
import MapKit

struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct RouteSteps : Identifiable {
    let id = UUID()
    let step : String
    
}

struct ContentView: View {
    var body: some View {
        VStack {
            //Map kit map
            
            //Form with textfields
            
            //Picker
            
            //List1234
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
