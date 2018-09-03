////
//  TestViewController.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 13.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GooglePlacePicker
import Alamofire
import CoreData

enum LocationN {
    case startLocation
    case destinationLocation
}

class DirectionViewController: TransportViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var startLocation: UITextField!
    @IBOutlet weak var destinationLocation: UITextField!

    
    var locationManager = CLLocationManager()
    var locationSelected = LocationN.startLocation
    
    var locationStart = CLLocation()
    var locationEnd = CLLocation()
    var isPPVC = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLocation()
        
        if #available(iOS 11.0, *) {
//            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
//        let frame = CGRect(x: 0, y: 0, width: viewMap.frame.width, height: viewMap.frame.height)
        var height = view.frame.height-64-98-49-46
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: height)
        mapView = GMSMapView.map(withFrame: frame, camera: city.camera)
        if UIScreen.main.nativeBounds.height == 2436 {
            height = view.frame.height-88-98-83-46
            mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: frame.width, height:height), camera: city.camera)
        }
        
        self.mapView?.camera = city.camera
        self.mapView?.delegate = self
        self.mapView?.isMyLocationEnabled = true
        self.mapView?.settings.myLocationButton = true
        self.mapView?.settings.compassButton = true
        self.mapView?.settings.zoomGestures = true
        self.viewMap.addSubview(mapView!)
        
    
        transport = TransportMap(self)
    }
    
    
    fileprivate func setLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.toMapButton.isEnabled = false
        if isPPVC == false && self.startLocation.text == "" {
            self.checkUserAddress = true
        }
        isPPVC = false
        locationManager.startUpdatingLocation()
    }
    
    
    //MARK: - Location Manager delegates
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error to get location : \(error)")
    }
    var checkUserAddress = true
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        manager.stopUpdatingLocation()
        if checkUserAddress {
            DispatchQueue.global(qos: .userInteractive).async {
                GMSGeocoder().reverseGeocodeCoordinate(locations[0].coordinate) { (response, error) in
                    if let response = response {
                        let firstResult = response.firstResult()
                        guard let coordinate = (firstResult?.coordinate) else { return }
                        self.locationStart = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        self.checkUserAddress = false
                        self.startLocation.text = "\(coordinate.latitude),\(coordinate.longitude)"
                        guard let thoroughfare = (firstResult?.thoroughfare) else { return }
                        self.startLocation.text = "\(thoroughfare)"
                        guard let locality = (firstResult?.locality) else { return }
                        self.startLocation.text = "\(thoroughfare), \(locality)"
                        guard let administrativeArea = (firstResult?.administrativeArea) else { return }
                        self.startLocation.text = "\(thoroughfare), \(locality), \(administrativeArea)"
                        guard let country = (firstResult?.country) else { return }
                        self.startLocation.text = "\(thoroughfare), \(locality), \(administrativeArea), \(country)"
                        guard let postalCode = (firstResult?.postalCode) else { return }
                        self.startLocation.text = "\(thoroughfare), \(locality), \(administrativeArea), \(country), \(postalCode)"
                        
                        if self.destinationLocation.text != "" {
                            self.drawPath(startLocation: self.locationStart, endLocation: self.locationEnd)
                        }
                    }
                }
            }
        }
        let coordinateFrom = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        let coordinateTo = CLLocation(latitude: city.camera.target.latitude, longitude: city.camera.target.longitude)
        
        let distanceInMeters = coordinateFrom.distance(from: coordinateTo)
        if distanceInMeters/1000 < 100 {
            self.mapView?.camera = GMSCameraPosition.camera(withLatitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude, zoom: 15.0)
        } else {
            self.mapView?.camera = GMSCameraPosition.camera(withLatitude: coordinateTo.coordinate.latitude, longitude: coordinateTo.coordinate.longitude, zoom: 15.0)
        }
    }
    
    func placePick() {
        var center = CitySettings.shared.camera.target
        if let myLoc = mapView?.myLocation?.coordinate {
            center = myLoc
        }
        let northEast = CLLocationCoordinate2D(latitude: (center.latitude) + 0.001, longitude: (center.longitude) + 0.001)
        let southWest = CLLocationCoordinate2D(latitude: (center.latitude) - 0.001, longitude: (center.longitude) - 0.001)
        let viewport = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
        let config = GMSPlacePickerConfig(viewport: viewport)
        let placePicker = GMSPlacePickerViewController(config: config)
        
        placePicker.delegate = self as GMSPlacePickerViewControllerDelegate
        self.present(placePicker, animated: true, completion: nil)
    }
    
    // MARK: - GMSMapViewDelegate
    
    @IBAction func toAirport(_ sender: Any) {
        if self.startLocation.text != "" {
            self.drawPath(startLocation: self.locationStart, endLocation: CLLocation(latitude: 47.488453, longitude: 39.929837))
        }
        if Locale.preferredLanguages[0] == "ru-RU" {
            self.destinationLocation.text = "Аэропорт \"Платов\""
        } else {
            self.destinationLocation.text = "Airport \"Платов\""
        }
        self.locationEnd = CLLocation(latitude: 47.488453, longitude: 39.929837)
    }
    
    
    @IBAction func toStadium(_ sender: Any) {
        
        if self.startLocation.text != "" {
            self.drawPath(startLocation: self.locationStart, endLocation: CLLocation(latitude: 47.209411, longitude: 39.737442))
        }
        if Locale.preferredLanguages[0] == "ru-RU" {
            self.destinationLocation.text = "Ростов-Арена"
        } else {
            self.destinationLocation.text = "Rostov-Arena"
        }
        self.locationEnd = CLLocation(latitude: 47.209411, longitude: 39.737442)
        
    }
    
    
    override func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        super.mapView(mapView, idleAt: position)
        mapView.isMyLocationEnabled = true
    }
    
    override func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        super.mapView(mapView, willMove: gesture)
        mapView.isMyLocationEnabled = true
        
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    override func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let _ = super.mapView(mapView, didTap: marker)
        if marker.iconView != nil {
            return true
        }
        mapView.isMyLocationEnabled = true
        return false
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("COORDINATE \(coordinate)") // when you tapped coordinate
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.isMyLocationEnabled = true
        mapView.selectedMarker = nil
        return false
    }
    
    
    
    
    
    //MARK: - this is function for create direction path, from start location to desination location
    
    func drawPath(startLocation: CLLocation, endLocation: CLLocation) {
        mapView?.clear()
        let origin = "\(startLocation.coordinate.latitude),\(startLocation.coordinate.longitude)"
        let destination = "\(endLocation.coordinate.latitude),\(endLocation.coordinate.longitude)"
        var urlStr = "https://maps.googleapis.com/maps/api/directions/json?key=AIzaSyAJORpZbPuaktkYFBcMaXgOwMZSrd3WtFY&origin=\(origin)&destination=\(destination)&mode=transit&alternatives=false"

        print(urlStr)
        let url = URL(string: urlStr)!
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data {
                do {
                    let jsonDecoder = JSONDecoder()
                    let responseModel = try jsonDecoder.decode(Directions.self, from: data)
                    self.transportData =  TransportData(directions: responseModel)
                    self.transport = TransportMap(self)
                    if self.transport != nil {
                        self.transport.run()
                    }
//                    DrawRoute(for: (self.mapView)!, by: responseModel).draw()
                    self.direction = (routes: responseModel, start: startLocation, end: endLocation)
                    DispatchQueue.main.async {
//                        self.toMapButton.isEnabled = true
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            }.resume()
        
    }
    var direction: (routes: Directions, start: CLLocation, end: CLLocation)? = nil
    func createMarker(titleMarker: String, iconMarker: UIImage, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
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
            marker.title = self.startLocation.text
            textField.text = "A"
        } else if titleMarker == "Location End" {
            markerView.backgroundColor = .red
            marker.title = self.destinationLocation.text
            textField.text = "B"
        }
        markerView.addSubview(textField)
        marker.position = CLLocationCoordinate2DMake(latitude, longitude)
        marker.iconView = markerView
        marker.map = mapView
    }
    
    @IBOutlet weak var toMapButton: UIButton!
    @IBAction func toMapView(_ sender: Any) {
        
        self.performSegue(withIdentifier: "toMapDir", sender: self.direction)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapDir" {
            let mapView = (segue.destination as! MapViewController)
            mapView.transportData = TransportData(directions: (self.direction?.routes)!)
        }
    }
    
    @IBAction func openStartLocation(_ sender: UIButton) {
        locationSelected = .startLocation
        self.placePick()
        self.locationManager.stopUpdatingLocation()
    }
    
    
    @IBAction func openDestinationLocation(_ sender: UIButton) {
        locationSelected = .destinationLocation
        self.placePick()
    }
}

extension DirectionViewController: GMSPlacePickerViewControllerDelegate {
    func placePicker(_ viewController: GMSPlacePickerViewController, didPick place: GMSPlace) {
        var address = place.formattedAddress
        if address == nil {
            address = "\(place.coordinate.latitude),\(place.coordinate.longitude)"
        }
        if self.locationSelected == .startLocation {
            if self.destinationLocation.text != "" {
                self.drawPath(startLocation: CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude), endLocation: self.locationEnd)
            }
            self.startLocation.text = address
            self.locationStart = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        } else {
            if self.startLocation.text != "" {
                self.drawPath(startLocation: self.locationStart, endLocation: CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude))
            }
            self.destinationLocation.text = address
            self.locationEnd = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        }
        isPPVC = true
        self.dismiss(animated: true, completion: nil)
    }
    
    func placePickerDidCancel(_ viewController: GMSPlacePickerViewController) {
        isPPVC = true
        self.dismiss(animated: true, completion: nil)
    }
    
}

public extension UISearchBar {
    
    public func setTextColor(color: UIColor) {
        let svs = subviews.flatMap { $0.subviews }
        guard let tf = (svs.filter { $0 is UITextField }).first as? UITextField else { return }
        tf.textColor = color
    }
    
}
