//
//  CSVRKCProvider.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 20/06/2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import GoogleMaps

class CSVRKCProvider: TransportProvider {
    func markerSettings(_ data: Data) -> [MarkerSettingsData]? {
        guard let info = String(data: data, encoding: .utf8) else { return nil }
        let elements = info.components(separatedBy: .newlines)
        var markerSettingsArray = [MarkerSettingsData]()
        for el in elements {
            if el != "" {
                guard let ms = parseString(el) else { continue }
                markerSettingsArray.append(ms)
            }
        }
        return markerSettingsArray
    }
    
    fileprivate func parseString(_ data: String) -> MarkerSettings?  {
        var markerSettings = MarkerSettings()
        let el = data.components(separatedBy: ",")
        if el.count > 6 {
            markerSettings.number = el[6]
            markerSettings.route = el[1]
            if el[4] == "" {
                markerSettings.speed = -1
            } else {
                markerSettings.speed = Int(el[4])
            }
            
            if el[5] == "" {
                markerSettings.degrees = -1
            } else {
                markerSettings.degrees = Double(el[5])
            }
            
            markerSettings.lat = parsCord(el[3])
            markerSettings.lng = parsCord(el[2])
            switch Int(el[0])! {
            case 2:
                markerSettings.carType = .bus
            case 4:
                markerSettings.carType = .minibus
            case 3:
                markerSettings.carType = .tram
            case 6:
                markerSettings.carType = .meg
            case 1:
                markerSettings.carType = .trolleybus
            default: break
            }
            return markerSettings
        }
        return nil
    }
    
    fileprivate func parsCord(_ data: String) -> Double {
        var cord = data
        cord.insert(".", at: data.index(data.startIndex, offsetBy: 2))
        return Double(cord)!
    }
}
