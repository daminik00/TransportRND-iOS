//
//  ViewController.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 03.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit
import GoogleMaps
import CoreData
import Appodeal
import SVProgressHUD

class MapViewController: TransportViewController, CLLocationManagerDelegate {
    var locUpdate = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.transportData?.type.count != 0 {
            self.title = Car.getInfo(type: (self.transportData?.type[0])!).nameRuS
        }
        self.cameraPosition = (topLeftLat: 47.508768,
                               topLeftLng: 39.338706,
                               topRightLng: 40.098136,
                               bottomLeftLat: 47.079389)
        self.checkCity()
        self.setMap()
        SVProgressHUD.show()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        determineMyCurrentLocation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    fileprivate func setMap() {
        mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 64, width: view.bounds.width, height: view.bounds.height-64-49), camera: city.camera)
        if UIScreen.main.nativeBounds.height == 2436 {
            mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 88, width: view.bounds.width, height: view.bounds.height-88-83), camera: city.camera)
        }
        transport = TransportMap(self)
        view.addSubview(mapView!)
        setZoom()
        self.mapView?.settings.rotateGestures = false;
        self.mapView?.settings.tiltGestures = false;
        self.mapView?.delegate = self
        locUpdate = true
        transport.run()
    }
    

    var locationManager: CLLocationManager!
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        if locUpdate {
            manager.stopUpdatingLocation()
        }
        let coordinate1 = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let coordinate2 = CLLocation(latitude: city.camera.target.latitude, longitude: city.camera.target.longitude)
        
        let distanceInMeters = coordinate1.distance(from: coordinate2)
        if distanceInMeters/1000 < 100 {
            self.mapView?.settings.myLocationButton = true
            self.mapView?.isMyLocationEnabled = true
            self.mapView?.camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 15.0)
            setZoom()
            self.mapView?.settings.rotateGestures = false;
            self.mapView?.settings.tiltGestures = false;
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goCat" {
            self.updateFlag = false
            let view = (segue.destination as! TypeViewController)
            navigationController?.popViewController(animated: true)
            view.city = self.city
        }
    }
    
    fileprivate func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    fileprivate func setZoom() {
        if self.transportData?.direction.count != 0 {
            self.mapView?.setMinZoom(10, maxZoom: 20)
        } else {
            if self.transportData?.type.first == .all {
                self.mapView?.setMinZoom(15, maxZoom: 20)
            } else {
                let type = self.transportData?.type.first
                if type == .meg || type == .tram || type == .trolleybus || type == .bus || type == .minibus || self.types[0].city != .rostov || self.transportData?.directions != nil || type == .fav {
                    self.mapView?.setMinZoom(10, maxZoom: 20)
                } else {
                    self.mapView?.setMinZoom(15, maxZoom: 20)
                }
            }
        }
    }
    
}

extension MapViewController {
    
    func checkCity() {
        do {
            let fetchRequest: NSFetchRequest<CityData> = CityData.fetchRequest()
            let cities = try self.context.fetch(fetchRequest)
            if cities.count > 0 {
                switch (cities.last?.name)! {
                case "Ростов":
                    self.city = CitySettings(city: .rostov)
                case "Краснодар":
                    self.city = CitySettings(city: .krasnodar)
                case "Челябинск":
                    self.city = CitySettings(city: .chelyabinsk)
                default:
                    self.city = CitySettings(city: .rostov)
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
}









