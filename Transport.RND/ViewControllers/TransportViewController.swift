//
//  TransportViewController.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 22.04.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps
import CoreData
import ChameleonFramework

protocol TransportDelegate {
    var route: String? { get }
    var type: CarType? { get }
    var city: CitySettings { get }
    var direction: (routes: Directions, start: CLLocation, end: CLLocation)? { get set }
}

protocol CameraPositionDelegate {
    var cameraPosition: (topLeftLat: Double, topLeftLng: Double, topRightLng: Double, bottomLeftLat: Double)? { get set }
}

class TransportViewController: UIViewController, CameraPositionDelegate {
    weak var transport: TransportMap!
    
//    var pb = UIProgressView()
    
    var mapView: GMSMapView?
    var updateFlag = true
    var repeatThis = true
    var types = [(route: String, type: CarType, city: City)]()
    var cameraPosition: (topLeftLat: Double, topLeftLng: Double, topRightLng: Double, bottomLeftLat: Double)?
    var context: NSManagedObjectContext!
    
    var city = CitySettings()
    var type: CarType? = nil
    var route: String? = nil
    
    var transportData: TransportData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        self.updateFlag = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = transport {
            transport.start()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateFlag = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let _ = transport {
            transport.stop()
        }
        TransportManager.shared.removeAll()
    }
    
    
}

extension TransportViewController: TransportMapDelegate {
    var viewScreen: UIView {
        return self.view
    }
}


extension TransportViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let projection = mapView.projection.visibleRegion()
        self.cameraPosition = (topLeftLat: projection.farLeft.latitude,
                               topLeftLng: projection.farLeft.longitude,
                               topRightLng: projection.farRight.longitude,
                               bottomLeftLat: projection.nearLeft.latitude)
            TransportManager.shared.updateAll { (lat, lng) -> Bool in
                return Utils.checkPosition(lat, lng: lng, delegate: self)
            }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        guard let _ = marker.icon else {
            if transport != nil {
                transport.showInfoView(marker: marker)
            }
            return true
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.updateFlag = false
        print("move start")
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.updateFlag = true
        print("move stop")
    }
    
}
