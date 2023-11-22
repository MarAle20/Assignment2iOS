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
    @State var fetch = GetData()
    
    let defaultCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var selectedOption = 3
    let options = ["Stops1", "Stops2","Destinations","All"]
    
    
    @State private var theRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.319312, longitude: -122.028336), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var body: some View {
        VStack{
            
            Text("Stops and Destinations")
            
            Map(coordinateRegion: $theRegion, showsUserLocation: true, annotationItems: getAnnotations(selectedOption)){ item in
                MapMarker(coordinate: item.coordinate,tint: item.color)
            }.onAppear{
                viewModel.checkIfLocationServiceIsEnabled()
            }
            List {
                Section(header: Text("\(options[selectedOption])")){
                    ForEach(getAnnotations(selectedOption)) { item in
                        Text("Coordinates: \(item.coordinate.latitude),\(item.coordinate.longitude).").onTapGesture {
                            setRegionC(item.coordinate)
                        }
                    }
                }
            }
            Picker("Select an Filter Option", selection: $selectedOption){
                ForEach(0..<options.count){ index in
                    Text(self.options[index]).tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
            
        }
    }
    
    private func setRegionC(_ option: CLLocationCoordinate2D) {
        self.theRegion = MKCoordinateRegion(center: option, span:MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    }
    
    func getAnnotations(_ option: Int) -> [PinLoc] {
        
        if option == 0 {
            return self.fetch.annotations1
        }
        if option == 1 {
            return self.fetch.annotations2
        }
        if option == 2 {
            return self.fetch.annotations3
        }
        if option == 3 {
            return self.fetch.annotations1 + self.fetch.annotations2 + self.fetch.annotations3
        }
        return self.fetch.annotations1 + self.fetch.annotations2 + self.fetch.annotations3
    }
}

