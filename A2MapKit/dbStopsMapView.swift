//
//  dbStopsMapView.swift
//  A2MapKit
//
//  Created by Default User on 11/21/23.
//

import SwiftUI
import CoreLocation
import MapKit




struct dbStopsMapView: View {
    @ObservedObject var fetch = GetData()
        
    let defaultCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var selectedOption = 0
    let options = ["Stops1", "Stops2","Destinations","All"]
    
    
    var body: some View {
        VStack{
            
            Text("Stops and Destinations")
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: fetch.annotations1 + fetch.annotations2 + fetch.annotations3){ item in
                MapMarker(coordinate: item.coordinate,tint: item.color)
            } .onAppear{
                viewModel.checkIfLocationServiceIsEnabled()
            }
            
            //List
            
            
            Picker("Select an Filter Option", selection: $selectedOption){
                ForEach(0..<options.count){ index in
                    Text(self.options[index]).tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
            Button(action: {
                print("FILTER BUTTON CLICKED: SELECTED OPTION \(options[selectedOption])")
            })
            {
                Text("Filter")
            }
        
        }
    }
}

struct dbStopsMapView_Previews: PreviewProvider {
    static var previews: some View {
        dbStopsMapView()
    }
}
