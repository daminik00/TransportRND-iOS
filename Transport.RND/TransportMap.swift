//
//  TransportMap.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 20.04.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import GoogleMaps
import UIKit
import CoreData
import SVProgressHUD

protocol TransportMapDelegate {
    var types: [(route: String, type: CarType, city: City)] { get set }
    var cameraPosition: (topLeftLat: Double, topLeftLng: Double, topRightLng: Double, bottomLeftLat: Double)? { get set }
    var mapView: GMSMapView? { get set }
    var updateFlag: Bool { get set }
    var repeatThis: Bool { get set }
    var viewScreen: UIView { get }
    
    var transportData: TransportData? { get set }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool)
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition)
    
    func updateStart()
    func updateEnd()
}

class TransportMap: NSObject {

    
    
    fileprivate var mapView: GMSMapView!
    fileprivate var delegate: TransportMapDelegate!

    fileprivate var type: CarType? = nil
    fileprivate var route: String? = nil
    fileprivate var types = [(route: String, type: CarType, city: City)]()
    var city = CitySettings.shared
    fileprivate var context: NSManagedObjectContext!
    
    let tList = TransportManager.shared
    
    init(_ _vc: TransportMapDelegate) {
        super.init()
        DispatchQueue.main.async {
            self.context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        }
        setMapView(_vc.mapView!)
        delegate = _vc
        types = delegate.types
        mapSet()
    }
    
    func setMapView(_ _mapView: GMSMapView) {
        tList.setMap(_mapView)
        self.mapView = _mapView
    }
    
    func getMapView() -> GMSMapView {
        return mapView
    }
    
    func run() {
        guard let _ = delegate else { return }
//        DispatchQueue.global(qos: .background).async {
            print("run")
            self.start()
            self.getTransport()
//        }
    }
    
    func start() {
        guard let _ = delegate else { return }
        delegate.updateFlag = true
        print("start")
    }
    
    func pause() {
        guard let _ = delegate else { return }
        DispatchQueue.global(qos: .background).async {
            self.delegate.updateFlag = false
            print("pause")
        }
    }
    
    func stop() {
        guard let _ = delegate else { return }
        pause()
        delegate.repeatThis = false
        tList.removeAll()
    }
    
    fileprivate var bounds = true
    fileprivate var carsForHand = [Car]()
    fileprivate var markersForHand = [Marker]()
    fileprivate func getTransport() {
        if self.delegate.updateFlag {
            self.delegate.updateStart()
            URLSession.shared.dataTask(with: URL(string: self.city.link)!) { (data, response, error) in
                if let data = data {
                    guard let markerSettingsArray = self.city.provider.markerSettings(data) else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            if self.delegate.repeatThis {
                                self.getTransport()
                                return
                            }
                            return
                        }
                        return
                    }
                    
                    for markerSettings in markerSettingsArray {
                        if let route = self.route, let type = self.type {
                            if markerSettings.route == route && markerSettings.carType == type {
                                self.setTransport(markerSettings)
                            }
                        } else if let type = self.type {
                            if type == .all {
                                self.setTransport(markerSettings)
                            } else if markerSettings.carType == self.type {
                                self.setTransport(markerSettings)
                            }
                        } else if self.types.count != 0 {
                            if self.types.contains(where: { el -> Bool in
                                if markerSettings.carType == el.type && markerSettings.route == el.route {
                                    return true
                                }
                                return false
                            }) {
                                self.setTransport(markerSettings)
                            }
                        }
                    }
                    
                    self.bounds = false
                    SVProgressHUD.dismiss()
                    self.delegate.updateEnd()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        if self.delegate.repeatThis {
                            self.getTransport()
                        }
                    }
                } else {
                    if self.delegate.repeatThis {
                        self.getTransport()
                        return
                    }
                }
            }.resume()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                if self.delegate.repeatThis {
                    self.getTransport()
                    return
                }
            }
        }
    }
    
    func setTransport(_ newValue: MarkerSettingsData) {
        guard let _ = newValue.lat else { return }
        guard let _ = newValue.lng else { return }
        let checkPosition = Utils.checkPosition(newValue.lat!, lng: newValue.lng!, delegate: self)
        self.tList.add(newValue, (checkPosition || bounds))
    }
    
    var infoView: InfoView?
    func showInfoView(marker: GMSMarker) {
        do {
            guard let snippet = marker.snippet else { return }
            let info = try JSONDecoder().decode(Info.self, from: snippet.data(using: .utf8)!)
            if let _ = infoView {
                infoView?.delete()
            }
            infoView = InfoView(self.delegate, info: info)
        } catch {
            print(error.localizedDescription)
        }
        self.mapView?.animate(toLocation: marker.position)
    }
    
    func mapSet() {
        guard let transportData = delegate.transportData else { return }
        city = transportData.city
        type = transportData.type.count == 0 ? nil : transportData.type[0]
        types = transportData.direction
        route = transportData.route.count == 0 ? nil : transportData.route[0]
        if let type = self.type {
            if let route = self.route {
                DrawRoute(for: self.mapView!).draw(by: type, for: route, on: (self.city.city))
            }
        }
        guard let directions = transportData.directions else { return }
        let _ = DrawRoute(for: mapView, by: directions)
        
    }
    
    func getCoreData() -> [SavedRoutes]? {
        do {
            let fetchRequest: NSFetchRequest<SavedRoutes> = SavedRoutes.fetchRequest()
            let savedRoutes = try self.context.fetch(fetchRequest)
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

extension TransportMap: CameraPositionDelegate {
    var cameraPosition: (topLeftLat: Double, topLeftLng: Double, topRightLng: Double, bottomLeftLat: Double)? {
        get { return self.delegate.cameraPosition }
        set {}
    }
}
