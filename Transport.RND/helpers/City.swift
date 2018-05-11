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


enum City: String {
    case rostov = "https://www.its-rnd.ru/pikasonline/p04ktwt0.txt"
    case krasnodar = "http://www.marsruty.ru/krasnodar/gps.txt"
    case chelyabinsk = "http://www.marsruty.ru/chelyabinsk/readdata.php"
}

class CitySettings {
    var city: City = .rostov
    
    var link: String {
        return city.rawValue
    }
    
    init(city: City) {
        self.city = city
    }
    init() {}
    var type: [CarType] {
        return types[city]!
    }
    
    var types: [City: [CarType]] = [
        .rostov: [.bus, .minibus, .tram, .trolleybus, .meg, .all],
        .krasnodar: [.bus, .tram, .trolleybus, .all],
        .chelyabinsk: [.bus, .minibus, .tram, .trolleybus, .all]
    ]
    
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

