////
//  DrawRoute.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 17.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces


class DrawRoute {
    var mapView: GMSMapView?
    var direction: Directions?
    
    var polylines = [GMSPolyline]()
    
    init(for map: GMSMapView, by direction: Directions) {
        self.mapView = map
        self.direction = direction
        draw()
    }
    
    init(for map: GMSMapView) {
        self.mapView = map
    }
    
    func draw() {
        DispatchQueue.main.async {
            if let routes = self.direction?.routes {
                if routes.count > 0 {
                    let route = routes[0]
                    if let legs = route.legs {
                        if legs.count > 0 {
                            let leg = legs[0]
                            self.createMarker(titleMarker: "Location Start", latitude: (leg.start_location?.lat)!, longitude: (leg.start_location?.lng)!)
                            self.createMarker(titleMarker: "Location End", latitude: (leg.end_location?.lat)!, longitude: (leg.end_location?.lng)!)
                        }
                    }
                }
            }
        }
        for route in (direction?.routes!)! {
            for leg in route.legs! {
                for step in leg.steps! {
                    switch (step.travel_mode)! {
                    case "WALKING":
                        let path = GMSPath.init(fromEncodedPath: (step.polyline?.points)!)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 4
                        polyline.strokeColor = UIColor.blue
                        polyline.map = self.mapView
                    case "TRANSIT":
                        var name = step.transit_details?.line?.short_name
                        name = name?.components(separatedBy: "-")[0].components(separatedBy: "МТ")[0].components(separatedBy: "мт")[0].components(separatedBy: "MT")[0].components(separatedBy: "mt")[0]
                        let start = step.start_location
                        let marker = GMSMarker(position: CLLocationCoordinate2D(latitude: (start?.lat!)!, longitude: (start?.lng!)!))
                        marker.title = name
                        
                        var tips = "\(getNeedText("Остановка","Station")): \"\((step.transit_details?.departure_stop?.name)!)\""
                        tips += "\n\(getNeedText("Садитесь на", "Take the")) \(name!) "
                        marker.map = self.mapView
                        let path = GMSPath.init(fromEncodedPath: (step.polyline?.points)!)
                        let polyline = GMSPolyline.init(path: path)
                        polyline.strokeWidth = 4
                        switch (step.transit_details?.line?.vehicle?.type)! {
                        case "SHARE_TAXI":
                            polyline.strokeColor = Car.getInfo(type: .minibus).color
                            tips += "\(getNeedText("маршрутку", "minibus"))"
                        case "BUS":
                            let name = step.transit_details?.line?.short_name!
                            if name == "286" || name == "285" {
                                polyline.strokeColor = Car.getInfo(type: .meg).color
                            } else {
                                polyline.strokeColor = Car.getInfo(type: .bus).color
                            }
                            tips += "\(getNeedText("автобус", "bus"))"
                        case "TROLLEYBUS":
                            polyline.strokeColor = Car.getInfo(type: .trolleybus).color
                            tips += "\(getNeedText("троллейбус", "trolleybus"))"
                        case "TRAMWAY":
                            polyline.strokeColor = Car.getInfo(type: .tram).color
                            tips += "\(getNeedText("трамвай", "tram"))"
                        default:
                            polyline.strokeColor = .black
                            tips += (step.transit_details?.line?.vehicle?.name)!
                        }
                        tips += "\n\(getNeedText("В направление", "In the direction")) \((step.transit_details?.arrival_stop?.name)!)\n"
                        tips += "\(getNeedText("Количество остановок", "Number of stops")): \((step.transit_details?.num_stops)!)"
                        marker.snippet = tips
                        marker.icon = #imageLiteral(resourceName: "map-imfo-1")
                        polyline.map = self.mapView
                    default: break
                    }
                }
            }
        }
    }
    
    func getNeedText(_ ru: String, _ en: String) -> String {
        if Locale.preferredLanguages[0] == "ru-RU" {
            return ru
        } else {
            return en
        }
    }
    
    
    fileprivate func prepareRoute(_ data: Data, _ type: CarType, _ route: String, _ path: String) {
        do {
            
            let htmlContext = String(data: data, encoding: .utf8)!
            let _ = writingFile(name: path, textToWrite: htmlContext)
            var regExp = try? NSRegularExpression(pattern: "a-b\r\n(.*)\r\n")
            var matches = regExp?.matches(in: htmlContext, range: htmlContext.toNSRange)
            let aB = self.getMatch(matches: matches, separatedBy: "a-b\r\n", in: htmlContext)
            regExp = try? NSRegularExpression(pattern: "b-a\r\n(.*)\r\n")
            matches = regExp?.matches(in: htmlContext, range: htmlContext.toNSRange)
            let bA = self.getMatch(matches: matches, separatedBy: "b-a\r\n", in: htmlContext)
            
            let pathA = GMSPath.init(fromEncodedPath: aB!)
            let pathB = GMSPath.init(fromEncodedPath: bA!)
            DispatchQueue.main.async {
                self.setPolyline(by: pathA!, with: Car.getInfo(type: type).color)
                self.setPolyline(by: pathB!, with: Car.getInfo(type: type).colorB)
            }
            
            URLSession.shared.dataTask(with: URL(string: "http://supremebot.ru/api/route/get?one_direction=false")!, completionHandler: { (data, response, error) in
                if let data = data {
                    do {
                        let routes = try JSONDecoder().decode([AllRoutes].self, from: data)
                        for r in routes {
                            if r.getType() == type && r.number! == route {
                                
                                URLSession.shared.dataTask(with: URL(string: "http://supremebot.ru/api/stop/getByRouteId?id=\(r.id!)")!, completionHandler: { (data, response, error) in
                                    if let data = data {
                                        do {
                                            let stops = try JSONDecoder().decode([Stops].self, from: data)
                                            for stop in stops {
                                                let marker = GMSMarker()
                                                marker.position = CLLocationCoordinate2D(latitude: stop.lng!, longitude: stop.lat!)
                                                //                                                        marker.map = map
                                            }
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    }
                                }).resume()
                                
                                break
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            })//.resume()
            
        }
    }
    
    func draw(by type: CarType, for route: String, on city: City) {
        var route = route.replacingOccurrences(of: "Д", with: "d")
        route = route.replacingOccurrences(of: "A", with: "a")
        var url = "\(Car().routePath)\(Car.getInfo(type: type).points)\(route).txt"
        var path = "\(Car.getInfo(type: type).points)\(route).txt"
        if city == .chelyabinsk {
            url = "http://www.marsruty.ru/chelyabinsk/chelyabinsk/chelyabinsk_\(Car.getInfo(type: type).points)\(route).txt"
            path = "chelyabinsk_\(Car.getInfo(type: type).points)\(route).txt"
        } else if city == .krasnodar {
            url = "http://www.marsruty.ru/krasnodar/krasnodar//krasnodar_\(Car.getInfo(type: type).points)\(route).txt"
            path = "krasnodar_\(Car.getInfo(type: type).points)\(route).txt"
        }
        print(path)
        
        let text = readFile(name: path)
        if text == "false" {
            print("Файла нет, грузим из интернета")
            URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
                if let data = data {
                    self.prepareRoute(data, type, route, path)
                } else {
                    print(error!.localizedDescription)
                }
                }.resume()
        } else {
            print("Файл есть")
            self.prepareRoute(text.data(using: .utf8)!, type, route, path)
        }
    }
    
    func setPolyline(by path: GMSPath, with color: UIColor) {
        var polyline = GMSPolyline.init(path: path)
        polyline.strokeWidth = 5
        polyline.strokeColor = .white
        polyline.map = self.mapView
        polylines.append(polyline)
        polyline = GMSPolyline.init(path: path)
        polyline.strokeWidth = 4
        polyline.strokeColor = color
        polyline.map = self.mapView
        polylines.append(polyline)
    }
    
    fileprivate func getMatch(matches: [NSTextCheckingResult]?, separatedBy: String, in htmlContext: String) -> String? {
        for match in matches! {
            let text = htmlContext.substringFromNSRange(with: match.range)
            let route = text?.components(separatedBy: separatedBy)[1].components(separatedBy: "\r\n")[0]
            return route
        }
        return nil
    }
    
    func createMarker(titleMarker: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let marker = GMSMarker()
        let markerView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        markerView.layer.borderColor = UIColor.white.cgColor
        markerView.layer.borderWidth = 2
        markerView.layer.cornerRadius = 10
        textField.font = UIFont(name: "Futura", size: 10)
        textField.textColor = .white
        textField.textAlignment = .center
        if titleMarker == "Location Start" {
            markerView.backgroundColor = .blue
            marker.title = "Начало"
            marker.snippet = (self.direction?.routes![0].legs![0].start_address)!
            textField.text = "A"
        } else if titleMarker == "Location End" {
            markerView.backgroundColor = .red
            marker.title = "Конец"
            marker.snippet = (self.direction?.routes![0].legs![0].end_address)!
            textField.text = "B"
        }
        markerView.addSubview(textField)
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.iconView = markerView
        marker.map = mapView
    }
    
    func readFile(name: String) -> String {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(name)
            do {
                let text = try String(contentsOf: fileURL, encoding: .utf8)
                return text
            }
            catch {
                return "false"
            }
        }
        return "false"
    }
    
    func writingFile(name: String, textToWrite: String) -> Bool {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(name)
            do {
                try textToWrite.write(to: fileURL, atomically: false, encoding: .utf8)
                return true
            }
            catch {
                return false
            }
        }
        return false
    }
}

