//
//  DataRostovFusion.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 17/06/2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON


class RostovFusionProvider: TransportProvider {
    
    func markerSettings(_ data: Data) -> [MarkerSettingsData]? {
        
        do {
            let json = try JSON(data: data)
            var markersSet = [MarkerSettingsData]()
            for el in json.array! {
                if let routeType = el["route_type"].string {
                    var mf = MarkerSettingsFusion()
                    switch routeType {
                    case "bus":
                        mf.carType = .bus
                    case "minibus":
                        mf.carType = .minibus
                    case "shuttles", "suburban":
                        mf.carType = .meg
                    case "tram":
                        mf.carType = .tram
                    case "trolleybus":
                        print("Должен быть троллейбус", el)
                        mf.carType = .trolleybus
                    default: break
                    }
                    
                    guard let degrees = el["azimut"].int else { continue}
                    var lng = Double()
                    if el["lon"].double != nil {
                       lng = el["lon"].double!
                    } else if el["lon"].string != nil {
                        guard let _lng = Double(el["lon"].string!) else { continue }
                        lng = _lng
                    } else {
                        continue
                    }
                    var lat = Double()
                    if el["lat"].double != nil {
                        lat = el["lat"].double!
                    } else if el["lat"].string != nil {
                        guard let _lat = Double(el["lat"].string!) else { continue }
                        lat = _lat
                    } else {
                        continue
                    }
                    guard let number = el["state_num"].string else { continue }
                    guard let route = el["route_short_name"].string else { continue }
                    guard let speed = el["speed"].int else { continue }
                    guard let key = el["device_number"].string else { print("device_number", "ERROR"); continue }
                    mf.key = key
                    mf.degrees = Double(degrees)
                    mf.lat = lat
                    mf.lng = lng
                    mf.number = number
                    mf.route = route
                    mf.speed = speed
                    markersSet.append(mf)
                }
            }
            return markersSet
        } catch {
            print("Ошибка", error.localizedDescription)
        }
        return nil
    }
    
    
}


struct MarkerSettingsFusion: MarkerSettingsData {
    var route: String?
    var number: String?
    var degrees: CLLocationDegrees?
    var speed: Int?
    var lat: Double?
    var lng: Double?
    var carType: CarType!
    var key: String?
    
    var primaryKey: String? {
        return key
    }
    
    var marker: Marker {
        let marker = Marker(by: self)
        return marker
    }
}

protocol TransportProvider {
    func markerSettings(_ data: Data) -> [MarkerSettingsData]?
}
