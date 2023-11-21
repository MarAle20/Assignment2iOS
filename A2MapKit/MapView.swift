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
    
    @State private var formIsExpanded = true
    
    @StateObject private var viewModel = ContentViewModel()
    
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
    
    @State var RSStartToStop1: [RouteSteps] = []
    @State var RSStop1ToStop2: [RouteSteps] = []
    @State var RSStop2ToFinalStop: [RouteSteps] = []
    
    var body: some View {
        
        VStack{
            
            Map(coordinateRegion: $viewModel.region, showsUserLocation: true, annotationItems: annotations1 + annotations2 + annotations3){ item in
                MapMarker(coordinate: item.coordinate)
            }
                .onAppear{
                    viewModel.checkIfLocationServiceIsEnabled()
                }
            
            DisclosureGroup(isExpanded: $formIsExpanded,content: {
                
                Section(header: Text("Insert Destinations")){
                    
                    TextField("First Stop", text: $firstStopText, onCommit: {
                        searchLocationAndAddPin(location: firstStopText, stopNumber: "1")
                    })
                    
                    TextField("Second Stop", text: $secondStopText, onCommit: {
                        searchLocationAndAddPin(location: secondStopText, stopNumber: "2")
                    })
                    
                    TextField("Final Destination", text: $finalDestinationText, onCommit: {
                        searchLocationAndAddPin(location: finalDestinationText, stopNumber: "3")
                    })
                }.padding(10)
                
                Section(header: Text("Select Navigation Type")) {
                    Picker("", selection: $selectedNavigation){
                        ForEach(0..<navigationOptions.count, id: \.self){
                            Text(self.navigationOptions[$0])
                        }
                    }.pickerStyle(MenuPickerStyle())
                }.padding(10)
                
                Button(action: {                    
                    calculateRoute()
                    formIsExpanded = false
                }){Text("Begin Navigation")}.padding(10)
                
                Button(action: {
                    let defaultCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                    // Stop1
                    saveStopsOnDatabase(loc: annotations1.first?.coordinate ?? defaultCoordinates , t: 1)
                    // Stop2
                    saveStopsOnDatabase(loc: annotations2.first?.coordinate ?? defaultCoordinates, t: 2)
                    //Destination
                    saveStopsOnDatabase(loc: annotations3.first?.coordinate ?? defaultCoordinates, t: 3)
                }){
                    Text("Save Stops and Destinations")
                }
                
            }, label: {Text("Navigation Form")})
                

            List{
                if !RSStartToStop1.isEmpty {
                    Section(header: Text("Start to Stop 1")){
                        ForEach(RSStartToStop1) { item in
                            Text(item.step)
                        }
                    }
                }

                if !RSStop1ToStop2.isEmpty {
                    Section(header: Text("Stop 1 to Stop 2")){
                        ForEach(RSStop1ToStop2) { item in
                            Text(item.step)
                        }
                    }
                }

                if !RSStop2ToFinalStop.isEmpty {
                    Section(header: Text("Stop 2 to Final Destination")){
                        ForEach(RSStop2ToFinalStop) { item in
                            Text(item.step)
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }.padding()
    }
    
    
    func saveStopsOnDatabase(loc: CLLocationCoordinate2D, t: Int){
        let location: CLLocationCoordinate2D = loc

        let url = URL(string: "http://alejanma.dev.fast.sheridanc.on.ca/iosa3/insertRow.php")!
        
        let coordinateString = "\(location.latitude),\(location.longitude)"
        let type = t
                
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Construct the body as form-data
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [
            URLQueryItem(name: "coordinate", value: coordinateString),
            URLQueryItem(name: "type", value: "\(type)")
        ]
        
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle the response here
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let responseString = String(data: data, encoding: .utf8)
                print("Response: \(responseString ?? "")")
            }
        }.resume()
                
    }

    
    func calculateRoute(){
        
        let navigationType = selectedNavigation
        
        //Clean all route steps from all 3 routeLists
        RSStartToStop1.removeAll()
        RSStop1ToStop2.removeAll()
        RSStop2ToFinalStop.removeAll()
        
        var defaultCoordinates = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let request = MKDirections.Request()
        
        if (navigationType == 0 || navigationType == 1){
            //Calculate start to stop1
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: viewModel.userLocation ,  addressDictionary: nil))
            
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotations1.first?.coordinate ?? defaultCoordinates, addressDictionary: nil))
            
            request.requestsAlternateRoutes = false
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate (completionHandler: { response, error in
                
                for route in (response?.routes)! {
                    
                    self.RSStartToStop1 = []
                    for step in route.steps {
                        self.RSStartToStop1.append(RouteSteps(step: step.instructions))
                    }
                }
            })        }
        
        if(navigationType == 0 || navigationType == 2){
            //Calculate stop1 to stop2
            request.source = MKMapItem(placemark: MKPlacemark(coordinate:
                                                                annotations1.first?.coordinate ?? defaultCoordinates,  addressDictionary: nil))
            
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotations2.first?.coordinate ?? defaultCoordinates, addressDictionary: nil))
            
            request.requestsAlternateRoutes = false
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate (completionHandler: { response, error in
                
                for route in (response?.routes)! {
                    
                    self.RSStop1ToStop2 = []
                    for step in route.steps {
                        self.RSStop1ToStop2.append(RouteSteps(step: step.instructions))
                    }
                }
            })
        }
        
        if(navigationType == 0){
            //Calculate step 2 to final destination
            request.source = MKMapItem(placemark: MKPlacemark(coordinate:
                                                                annotations2.first?.coordinate ?? defaultCoordinates,  addressDictionary: nil))
            
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: annotations3.first?.coordinate ?? defaultCoordinates, addressDictionary: nil))
            
            request.requestsAlternateRoutes = false
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate (completionHandler: { response, error in
                
                for route in (response?.routes)! {
                    
                    self.RSStop2ToFinalStop = []
                    for step in route.steps {
                        self.RSStop2ToFinalStop.append(RouteSteps(step: step.instructions))
                    }
                }
            })
        }
    
    }
    
    private func searchLocationAndAddPin(location: String, stopNumber: String){
    
        print("Location")
        print(location)
        
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
    
    @Published var userLocation = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
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
            
            userLocation = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
            
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
