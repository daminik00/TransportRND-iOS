//
//  MarkerView.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 05.05.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import UIKit

class MarkerView: UIView {
    
    init(type: CarType, route: String?) {
        super.init(frame: CGRect(x: 0, y: 5, width: 20, height: 25))
        let markerView = UIView(frame: CGRect(x: 0, y: 5, width: 20, height: 20))
        let triangle = TriangleView(frame: CGRect(x: 2, y: 0, width: 16 , height: 10))
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        let info = Car.getInfo(type: type)
        markerView.layer.borderColor = UIColor.white.cgColor
        markerView.layer.borderWidth = 2
        triangle.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
        markerView.backgroundColor = info.color
        triangle._color = info.color
        
        markerView.layer.cornerRadius = 10
        
        self.addSubview(triangle)
        self.addSubview(markerView)
        
        guard let route = route else {
            return
        }
        do {
            if route.count > 2 {
                textField.font = UIFont(name: "Futura", size: 7)
            } else {
                textField.font = UIFont(name: "Futura", size: 10)
            }
            textField.text! = route
            textField.textColor = .white
        }
        textField.textAlignment = .center
        markerView.addSubview(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
