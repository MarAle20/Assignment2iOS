//
//  MapView.swift
//  A2MapKit
//
//  Created by Default User on 10/27/23.
//

import SwiftUI
import MapKit
import CoreLocation


struct Location: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
}

struct RouteSteps : Identifiable {
    let id = UUID()
    let step : String
    
}

struct MapView: View {
    
    @StateObject private var viewModel = ContentViewModel()
    
    @State private var userLocation: MapUserTrackingMode = .follow
    
    //User Input
    @State private var firstStopText: String = ""
    @State private var secondStopText: String = ""
    @State private var finalDestinationText: String = ""
    
    @State private var selectedNavigation = 0
    let navigationOptions = ["Start -> Stop1 -> Stop2 -> Destination","Start -> Stop1", "Stop1 -> Stop2"]
    
    //Annotation aka PINS / One for each textfield so if we change one stop we remove old stop with new one.
    @State private var annotations1: [Location] = []
    @State private var annotations2: [Location] = []
    @State private var annotations3: [Location] = []
    
    
    var body: some View {
        
        VStack{
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: annotations1 + annotations2 + annotations3){ item in
                MapMarker(coordinate: item.coordinate)
            }
                .ignoresSafeArea()
                .onAppear{
                    viewModel.checkIfLocationServiceIsEnabled()
                }
            
            VStack {
                Form{
                    Section(header: Text("Destinations")){
                        
                        TextField("First Stop", text: $firstStopText, onCommit: {
                            searchLocationAndAddPin(location: firstStopText, stopNumber: "1")
                        })
                        
                        TextField("Second Stop", text: $secondStopText, onCommit: {
                                searchLocationAndAddPin(location: secondStopText, stopNumber: "2")
                        })
                        
                        TextField("Final Destination", text: $finalDestinationText, onCommit: {
                            searchLocationAndAddPin(location: finalDestinationText, stopNumber: "3")
                        })
                    }
                    Section(header: Text("Navigation Type")) {
                        Picker("", selection: $selectedNavigation){
                            ForEach(0..<navigationOptions.count, id: \.self){
                                Text(self.navigationOptions[$0])
                            }
                        }.pickerStyle(MenuPickerStyle())
                    }
                }
            }
        }
    }
    
    private func searchLocationAndAddPin(location: String, stopNumber: String){
    
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location){(placemarks, error) in
            if let error = error {
                print("Geocoding error!")
            } else if let placemarks = placemarks?.first{
                
                let coordinates: CLLocationCoordinate2D = placemarks.location!.coordinate
        
                //Making sure that if use changes stop then old stop will be removed for spefici stop.
                if stopNumber == "1"{
                    annotations1.removeAll()
                    annotations1.append(Location(name: placemarks.name!, coordinate: coordinates))
                }
                else if stopNumber == "2"{
                    annotations2.removeAll()
                    annotations2.append(Location(name: placemarks.name!, coordinate: coordinates))
                }else if stopNumber == "3"{
                    annotations3.removeAll()
                    annotations3.append(Location(name: placemarks.name!, coordinate: coordinates))
                }
                //Centering to newly added pin.
                viewModel.region.center = coordinates
                
            }
        }
    }

}

//HAD TO SEARCH ALL THIS TO BE ABLE TO ASK USER FOR LOCATION
final class ContentViewModel : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    
    var locationManager: CLLocationManager?
    
    func checkIfLocationServiceIsEnabled(){
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
        }else {
            print("Turn location if you want to use this app")
        }
    }
    
    private func checklocationAuthorization(){
        guard let locationManager = locationManager else {return}
        
        switch locationManager.authorizationStatus{
        
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Location is restricted")
        case .denied:
            print("You are denied")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span:MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            break
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checklocationAuthorization()
    }
}
