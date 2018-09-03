//
//  TransportData.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 22.04.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import CoreLocation
import CoreData
import UIKit

class TransportData {
    var city = CitySettings.shared
    var type = [CarType]()
    var route = [String]()
    var directions: Directions?
    
    var direction = [(route: String, type: CarType, city: City)]()
    
    init(type: CarType) {
        if type == .fav {
            if let data = getCoreData() {
                for d in data {
                    if d.city == self.city.city.rawValue {
                        direction.append((route: d.route!, type: CarType(rawValue: d.type!)!, city: City(rawValue: d.city!)!))
                    }
                }
            }
        } else {
            self.type.append(type)
        }
    }
    init(type: CarType, route: String) {
        self.type.append(type)
        self.route.append(route)
    }
    init(route: String) {
        self.route.append(route)
    }
    
    init(directions: Directions) {
        self.directions = directions
        for route in directions.routes! {
            for leg in route.legs! {
                for step in leg.steps! {
                    var name = step.transit_details?.line?.short_name
                    name = name?.components(separatedBy: "-")[0].components(separatedBy: "МТ")[0].components(separatedBy: "мт")[0].components(separatedBy: "MT")[0].components(separatedBy: "mt")[0]
                    switch (step.travel_mode)! {
                    case "TRANSIT":
                        switch (step.transit_details?.line?.vehicle?.type)! {
                        case "SHARE_TAXI":
                            print("minibus", name!)
                            self.direction.append((route: name!, type: .minibus, city: self.city.city))
                        case "BUS":
                            if name == "285" || name == "286" {
                                print("meg", name!)
                                self.direction.append((route: name!, type: .meg, city: self.city.city))
                            } else {
                                print("bus", name!)
                                self.direction.append((route: name!, type: .bus, city: self.city.city))
                            }
                        case "TROLLEYBUS":
                            print("troll", name!)
                            self.direction.append((route: name!, type: .trolleybus, city: self.city.city))
                        case "TRAMWAY":
                            print("tram", name!)
                            self.direction.append((route: name!, type: .tram, city: self.city.city))
                        default: break
                        }
                    default: break
                    }
                }
            }
        }
    }
    
    func getCoreData() -> [SavedRoutes]? {
        do {
            let fetchRequest: NSFetchRequest<SavedRoutes> = SavedRoutes.fetchRequest()
            let savedRoutes = try ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext.fetch(fetchRequest)
            if savedRoutes.count > 0 {
                return savedRoutes
            } else {
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
