//
//  InfoView.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 21.04.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import UIKit
import GoogleMaps


class InfoView: UIView {
    
    fileprivate let vc: TransportMapDelegate?
    fileprivate var drawRoute: DrawRoute?
    
    init(_ _vc: TransportMapDelegate, info: Info) {
        self.vc = _vc
        var frame = CGRect(x: 0, y: 64, width: (vc?.viewScreen.bounds.width)!, height: 55)
        if UIScreen.main.nativeBounds.height == 2436 {
            frame = CGRect(x: 0, y: 88, width: (vc?.viewScreen.bounds.width)!, height: 55)
        }
        drawRoute = DrawRoute(for: _vc.mapView!)
        drawRoute!.draw(by: CarType(rawValue: info.type!)!, for: info.route!, on: .rostov)
        
        super.init(frame: frame)
        self.backgroundColor = .white
        let closeView = UIImageView(frame: CGRect(x: frame.width-frame.height, y: 0, width: frame.height, height: frame.height))
        closeView.image = #imageLiteral(resourceName: "ic_close")
        let gesture = UITapGestureRecognizer(target: self, action:  #selector (self.close(_:)))
        closeView.isUserInteractionEnabled = true
        closeView.addGestureRecognizer(gesture)
        
        let typeView = UITextField(frame: CGRect(x: 5, y: 5, width: (vc?.viewScreen.bounds.width)!-55-5, height: 20))
        typeView.isUserInteractionEnabled = false
        let data = Car.getInfo(type: CarType(rawValue: info.type!)!)
        typeView.text = "\(data.nameRu): \(info.route!)"
        typeView.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        self.addSubview(typeView)
        
        let numberView = UITextField(frame: CGRect(x: 5, y: 25, width: (vc?.viewScreen.bounds.width)!-55-5, height: 20))
        numberView.isUserInteractionEnabled = false
        numberView.text = "\(info.number!)"
        numberView.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        self.addSubview(numberView)
        
        
        self.isUserInteractionEnabled = true
        self.addSubview(closeView)
        self.vc!.viewScreen.addSubview(self)
    }
    
    
    @objc func close(_ sender:UITapGestureRecognizer) {
        delete()
    }
    
    func delete() {
        for poli in drawRoute!.polylines {
            poli.map = nil
        }
        drawRoute!.polylines = [GMSPolyline]()
        self.removeFromSuperview()
    }
    
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
