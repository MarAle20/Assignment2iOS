//
//  GetData.swift
//  A2MapKit
//
//  Created by Default User on 11/21/23.
//

import UIKit
import MapKit
import SwiftUI

public struct Loc: Codable, Hashable {
            
    public var ID: String
    public var COORDINATES : String
    public var TYPE: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(COORDINATES)
    }
}

struct PinLoc: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let color : Color
}
class GetData: ObservableObject {
    @Published var locations = [Loc]()
    @Published var annotations1 = [PinLoc]()
    @Published var annotations2 = [PinLoc]()
    @Published var annotations3 = [PinLoc]()
    
    
    
    init() {
        let url = URL(string: "http://alejanma.dev.fast.sheridanc.on.ca/iosa3/retriveList.php")!
        
        URLSession.shared.dataTask(with: url){ (data,response,error) in
            do{
                if let locationsData = data{
                    let decodedData = try JSONDecoder().decode([Loc].self, from: locationsData)
                    DispatchQueue.main.sync {
                        print(decodedData)
                        self.locations = decodedData
                    }
                }
                
                for item in self.locations {
                    if(item.TYPE == "1"){
                        self.annotations1.append(PinLoc(coordinate: self.parseCoordinates(from: item.COORDINATES), color: Color.pink))
                    }
                    if(item.TYPE == "2"){
                        self.annotations2.append(PinLoc(coordinate: self.parseCoordinates(from: item.COORDINATES), color: Color.green))
                    }
                    if(item.TYPE == "3"){
                        self.annotations3.append(PinLoc(coordinate: self.parseCoordinates(from: item.COORDINATES), color: Color.yellow))
                    }
                }
                
            }catch{
                print("Error\(error)")
            }
        }.resume()
    }
    
    func requeueQuery (){
        let url = URL(string: "http://alejanma.dev.fast.sheridanc.on.ca/iosa3/retriveList.php")!
        
        URLSession.shared.dataTask(with: url){ (data,response,error) in
            do{
                if let locationsData = data{
                    let decodedData = try JSONDecoder().decode([Loc].self, from: locationsData)
                    DispatchQueue.main.sync {
                        print(decodedData)
                        self.locations = decodedData
                    }
                }
                
                self.annotations1.removeAll()
                self.annotations2.removeAll()
                self.annotations3.removeAll()
                
                for item in self.locations {
                    if(item.TYPE == "1"){
                        
                        self.annotations1.append(PinLoc(coordinate: self.parseCoordinates(from: item.COORDINATES), color: Color.pink))
                    }
                    if(item.TYPE == "2"){
                        self.annotations2.append(PinLoc(coordinate: self.parseCoordinates(from: item.COORDINATES), color: Color.green))
                    }
                    if(item.TYPE == "3"){
                        self.annotations3.append(PinLoc(coordinate: self.parseCoordinates(from: item.COORDINATES), color: Color.yellow))
                    }
                }
                
            }catch{
                print("Error\(error)")
            }
        }.resume()
        
    }
    
    func parseCoordinates(from string: String) -> CLLocationCoordinate2D {
        let component = string.components(separatedBy: ",")
        
        return CLLocationCoordinate2D(latitude: Double(component[0])!, longitude:Double(component[1])!)
    }
}
