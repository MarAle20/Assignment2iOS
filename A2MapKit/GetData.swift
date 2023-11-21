//
//  GetData.swift
//  A2MapKit
//
//  Created by Default User on 11/21/23.
//

import UIKit

public struct Loc: Codable, Hashable {
            
    public var ID: String
    public var COORDINATES : String
    public var TYPE: String
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(COORDINATES)
    }
}

class GetData: ObservableObject {
    @Published var locations = [Loc]()
    
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
            }catch{
                print("Error\(error)")
            }
        }.resume()
    }
}
