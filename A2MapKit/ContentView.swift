//
//  ContentView.swift
//  A2MapKit
//
//  Created by Default User on 10/27/23.
//

import SwiftUI
import MapKit



struct ContentView: View {
    
    var body: some View {
        NavigationView {
            
            ZStack{
               
                Color.green.edgesIgnoringSafeArea(.all)
                
                VStack{
                    
                    Text("A2 Mapkit Navigation App")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(10)
                    
                    Text("Made By: Marian Alejandro Heredia")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(10)
                    
                    
                    
                    NavigationLink(destination: MapView()){
                        Text("Go to Map Navigation")
                            .padding()
                            .background(Color.green.border(Color.white,width: 3))
                            .foregroundColor(.white)
                            .font(.headline)
                            .cornerRadius(5)
                    }.padding()
                }
            }
            
            
        }
    
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
