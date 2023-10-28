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
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
            .ignoresSafeArea()
            .onAppear{
                viewModel.checkIfLocationServiceIsEnabled()
            }
    }
}

//HAD TO SEARCH ALL THIS TO BE ABLE TO ASK USER FOR LOCATION
final class ContentViewModel : NSObject, ObservableObject, CLLocationManagerDelegate{
    
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
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
