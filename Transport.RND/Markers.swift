//
//  Markers.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 20.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import GoogleMaps

class Marker: GMSMarker {
    
    override var hashValue: Int {
        return (number?.hashValue)!
    }
    
    static func == (lhs: Marker, rhs: Marker) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var route: String?
    var number: String?
    var degrees: CLLocationDegrees?
    var speed: Int? {
        didSet(data) {
            self.setSnippet()
        }
    }
    var lat: Double?
    var lng: Double?
    
    
    var carType: CarType!
    
    var newPosition: CLLocationCoordinate2D {
        get {
            return position
        }
        set(data) {
            position = data
            moveMarker(coordinates: data, degrees: nil, duration: 4)
        }
    }
    
    override private init() {}
    
    init(by settings: MarkerSettings) {
        super.init()
        route = settings.route
        number = settings.number
        degrees = settings.degrees
        carType = settings.carType
        speed = settings.speed
        lat = settings.lat
        lng = settings.lng
        self.position = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
        DispatchQueue.main.async {
            self.setMarker(type: self.carType, route: self.route, speed: self.speed, number: self.number)
        }
    }
    
    var typeName = "Автобус"
    
    func setMarker(type: CarType, route: String?, speed: Int?, number: String?) {
        self.typeName = Car.getInfo(type: type).nameRu
        self.appearAnimation = GMSMarkerAnimation(rawValue: UInt(10))!
        DispatchQueue.main.async {
            self.iconView = MarkerView(type: type, route: route)
        }
        
        if let route = self.route {
            self.title = "\(self.typeName): \(route)"
        }
        if let _ = degrees {
            self.rotation = degrees!
        }
        self.setSnippet()
    }
    
    func setSnippet() {
        if let speed = self.speed {
            var json = ""
            if let number = self.number {
                json += "{\"number\": \"Гос. Номер: \(number)\","
            }
            if let route = self.route {
                json += "\"route\": \"\(route)\","
            }
            switch speed {
            case -1:
                json += "\"speed\": \"Скорость: нет данных\","
            case 0:
                json += "\"speed\": \"Скорость: стоит\","
            default:
                json += "\"speed\": \"Скорость: \(speed)км/ч\","
            }

            if let type = carType {
                json += "\"type\": \"\(type.rawValue)\"}"
            }
            DispatchQueue.main.async {
                self.snippet = json
            }
        }
    }
    
    init(position: CLLocationCoordinate2D) {
        super.init()
        self.position = position
    }
    
    func moveMarker(coordinates: CLLocationCoordinate2D, degrees: CLLocationDegrees?, duration: Double) {
        if let degrees = degrees {
            CATransaction.disableActions()
            CATransaction.begin()
            CATransaction.setAnimationDuration(duration)
            self.rotation = degrees
            CATransaction.commit()
        }
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        self.position = coordinates
        CATransaction.commit()
    }
    
}


struct MarkerSettings {
    var route: String?
    var number: String?
    var degrees: CLLocationDegrees?
    var speed: Int?
    var lat: Double?
    var lng: Double?
    var carType: CarType!
    
    init(by data: String) {
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
                self.degrees = -1
            } else {
                self.degrees = Double(el[5])
            }
            
            self.lat = parsCord(el[3])
            self.lng = parsCord(el[2])
            switch Int(el[0])! {
            case 2:
                carType = .bus
            case 4:
                carType = .minibus
            case 3:
                carType = .tram
            case 6:
                carType = .meg
            case 1:
                carType = .trolleybus
            default: break
            }
        }
    }
    
    fileprivate func parsCord(_ data: String) -> Double {
        var cord = data
        cord.insert(".", at: data.index(data.startIndex, offsetBy: 2))
        return Double(cord)!
    }
    
    var marker: Marker {
        let marker = Marker(by: self)
        return marker
    }
}
