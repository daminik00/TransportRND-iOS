//
//  Car.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 13.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps


extension String {
    // Вычислимое св-во, которое возвращает NSRange строки String
    var toNSRange: NSRange { return NSMakeRange(0, self.utf16.count) }
    
    // Метод возвращающий String по заданному NSRange
    func substringFromNSRange(with nsrange: NSRange) -> String? {
        guard let range = Range(nsrange) else { return nil }
        let start = String.UTF16Index(encodedOffset: range.lowerBound)
        let end = String.UTF16Index(encodedOffset: range.upperBound)
        return String(self.utf16[start..<end])
    }
}

struct Info: Codable {
    var number: String?
    var route: String?
    var speed: String?
    var type: String?
}

struct Car {
    var checkFlag = false
    
    var number: String?
    var route: String? = "0"
    var speed: Int? = 0
    var incline: Int?
    var lat: Double?
    var lng: Double?
    
    var marker: Marker?
    var type: CarType? = .tram
    init() {
        
    }
    
    init(data: String) {
        let el = data.components(separatedBy: ",")
        if el.count > 6 {
            self.number = el[6]
            self.route = el[1]
            if el[4] == "" {
                self.speed = -1
            } else {
                self.speed = Int(el[4])
            }
            
            if el[5] == "" {
                self.incline = -1
            } else {
                self.incline = Int(el[5])
            }
            
            self.lat = parsCord(el[3])
            self.lng = parsCord(el[2])
            switch Int(el[0])! {
            case 2:
                type = .bus
                self.getMarker(type!)
            case 4:
                type = .minibus
                self.getMarker(type!)
            case 3:
                type = .tram
                self.getMarker(type!)
            case 6:
                type = .meg
                self.getMarker(type!)
            case 1:
                type = .trolleybus
                self.getMarker(type!)
            default: break
            }
        }
    }
    
    
    static func getInfo(type: CarType) -> (nameEn: String, nameRu: String, nameRuS: String, color: UIColor, colorB: UIColor, points: String, image: UIImage?) {
        
        if Locale.preferredLanguages[0] == "ru-RU" {
            switch type {
            case .bus:
                return (nameEn: "bus", nameRu: "Автобус", nameRuS: "Автобусы", color: UIColor(red:0.86, green:0.19, blue:0.19, alpha:1.0), colorB: UIColor(red:0.86, green:0.19, blue:0.19, alpha:0.6), points: "bus_", image: #imageLiteral(resourceName: "bus"))
            case .minibus:
                return (nameEn: "minibus", nameRu: "Маршрутка", nameRuS: "Маршрутки", color: UIColor(red:1.00, green:0.40, blue:0.00, alpha:1.0), colorB: UIColor(red:1.00, green:0.40, blue:0.00, alpha:0.6), points: "minibus_", image: #imageLiteral(resourceName: "minibus"))
            case .trolleybus:
                return (nameEn: "trolleybus", nameRu: "Троллейбус", nameRuS: "Троллейбусы", color: UIColor(red:0.00, green:0.45, blue:0.67, alpha:1.0), colorB: UIColor(red:0.00, green:0.45, blue:0.67, alpha:0.6), points: "trol_", image: #imageLiteral(resourceName: "trolleybus"))
            case .tram:
                return (nameEn: "tram", nameRu: "Трамвай", nameRuS: "Трамваи", color: UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0), colorB: UIColor(red:0.00, green:0.60, blue:0.00, alpha:0.6), points: "tram_", image: #imageLiteral(resourceName: "tramway"))
            case .meg:
                return (nameEn: "meg", nameRu: "До \"Платова\"", nameRuS: "До аэропорта \"Платов\"", color: .black, colorB: .black, points: "suburbanbus_", image: #imageLiteral(resourceName: "meg"))
            case .all:
                return (nameEn: "all", nameRu: "Все", nameRuS: "Все", color: .black, colorB: .black, points: "bus_", image: #imageLiteral(resourceName: "all"))
            case .fav:
                return (nameEn: "favorites", nameRu: "Избранные", nameRuS: "Избранные", color: .black, colorB: .black, points: "bus_", image: #imageLiteral(resourceName: "fav"))
            }
        } else {
            switch type {
            case .bus:
                return (nameEn: "bus", nameRu: "Bus", nameRuS: "Buses", color: UIColor(red:0.86, green:0.19, blue:0.19, alpha:1.0), colorB: UIColor(red:0.86, green:0.19, blue:0.19, alpha:0.6), points: "bus_", image: #imageLiteral(resourceName: "bus"))
            case .minibus:
                return (nameEn: "minibus", nameRu: "Minibus", nameRuS: "Minibuses", color: UIColor(red:1.00, green:0.40, blue:0.00, alpha:1.0), colorB: UIColor(red:1.00, green:0.40, blue:0.00, alpha:0.6), points: "minibus_", image: #imageLiteral(resourceName: "minibus"))
            case .trolleybus:
                return (nameEn: "trolleybus", nameRu: "Trolleybus", nameRuS: "Trolleybuses", color: UIColor(red:0.00, green:0.45, blue:0.67, alpha:1.0), colorB: UIColor(red:0.00, green:0.45, blue:0.67, alpha:0.6), points: "trol_", image: #imageLiteral(resourceName: "trolleybus"))
            case .tram:
                return (nameEn: "tram", nameRu: "Tram", nameRuS: "Trams", color: UIColor(red:0.00, green:0.60, blue:0.00, alpha:1.0), colorB: UIColor(red:0.00, green:0.60, blue:0.00, alpha:0.6), points: "tram_", image: #imageLiteral(resourceName: "tramway"))
            case .meg:
                return (nameEn: "meg", nameRu: "To Airport", nameRuS: "To Airport \"Platov\"", color: .black, colorB: .black, points: "suburbanbus_", image: #imageLiteral(resourceName: "meg"))
            case .all:
                return (nameEn: "all", nameRu: "All", nameRuS: "All", color: .black, colorB: .black, points: "bus_", image: #imageLiteral(resourceName: "all"))
            case .fav:
                return (nameEn: "favorites", nameRu: "Featured", nameRuS: "Featured", color: .black, colorB: .black, points: "bus_", image: #imageLiteral(resourceName: "fav"))
            }
        }
    }
    
    let routePath = "https://www.its-rnd.ru/pikasonline/rostov/rostov_"
    
    
    var typeName = "Автобус"
    mutating func getMarker(_ type: CarType) {
//        let marker = Marker()
//        marker.setMarker(type: self.type!, route: self.route, speed: self.speed, number: self.number)
//        marker.position = CLLocationCoordinate2D(latitude: self.lat!, longitude: self.lng!)
//        
//        if let degrees = self.incline {
//            marker.rotation = Double(degrees)
//        }
//        self.marker = marker
    }
    
    fileprivate func parsCord(_ data: String) -> Double {
        var cord = data
        cord.insert(".", at: data.index(data.startIndex, offsetBy: 2))
        return Double(cord)!
    }
    
}

enum CarType: String {
    case bus = "bus"
    case minibus = "minibus"
    case trolleybus = "trolleybus"
    case tram = "tram"
    case meg = "meg"
    case all = "all"
    case fav = "favorites"
}
