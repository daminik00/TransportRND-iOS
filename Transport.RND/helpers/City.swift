//
//  Transport.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 03.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import RealmSwift

enum City: String {
    //case rostov = "http://80.80.98.215/api/ate/device"
    case rostov = "https://www.its-rnd.ru/pikasonline/p04ktwt0.txt"
    case krasnodar = "http://www.marsruty.ru/krasnodar/gps.txt"
    case chelyabinsk = "http://www.marsruty.ru/chelyabinsk/readdata.php"
}

class CitySettings {
    
    var city: City = .rostov
    
    var link: String {
        return city.rawValue
    }
    fileprivate init() {
        loadFromRealm()
    }
    
    static var shared = CitySettings()
    
    var type: [CarType] {
        return types[city]!
    }
    
    var types: [City: [CarType]] = [
        .rostov: [.bus, .minibus, .tram, .trolleybus, .meg, .all],
        .krasnodar: [.bus, .tram, .trolleybus, .all],
        .chelyabinsk: [.bus, .minibus, .tram, .trolleybus, .all]
    ]
    
    var transportProviders: [City: TransportProvider] = [
        //.rostov: RostovFusionProvider(),
        .rostov: CSVRKCProvider(),
        .krasnodar: CSVRKCProvider(),
        .chelyabinsk: CSVRKCProvider()
    ]
    
    var provider: TransportProvider {
        return transportProviders[city]!
    }
    
    var camera: GMSCameraPosition {
        return cameras[city]!
    }
    
    var route: String {
        return routes[city]!
    }
    
    fileprivate var cameras: [City: GMSCameraPosition] = [
        .rostov: GMSCameraPosition.camera(withLatitude: 47.225676, longitude: 39.717262, zoom: 15.0),
        .krasnodar: GMSCameraPosition.camera(withLatitude: 45.048190, longitude: 38.978289, zoom: 15.0),
        .chelyabinsk: GMSCameraPosition.camera(withLatitude: 55.162280, longitude: 61.389320, zoom: 15.0)
    ]
    
    fileprivate var routes: [City: String] = [
        .rostov: "http://api.daminik00.ru/res/routes.json",
        .krasnodar: "http://api.daminik00.ru/res/routesKras.json",
        .chelyabinsk: "http://api.daminik00.ru/res/routesChel.json"
    ]
    
}

class CityStore: Object {
    @objc dynamic var name: String = "rostov"
}


extension CitySettings {
    func writeToRealm() {
        let city = CityStore()
        switch self.city {
        case .rostov:
            city.name = "rostov"
        case .krasnodar:
            city.name = "krasnodar"
        case .chelyabinsk:
            city.name = "chelyabinsk"
        }
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(city)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadFromRealm() {
        do {
            let realm = try Realm()
            guard let city = realm.objects(CityStore.self).last else {
                return
            }
            switch city.name {
            case "rostov":
                self.city = .rostov
            case "krasnodar":
                self.city = .krasnodar
            case "chelyabinsk":
                self.city = .chelyabinsk
            default: self.city = .rostov
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

