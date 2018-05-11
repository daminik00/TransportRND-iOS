//
//  TriangleView.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 12.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class TriangleView: UIView {
    var _color: UIColor! = UIColor.blue
    var _margin: CGFloat! = 0
    
    @IBInspectable var margin: Double {
        get { return Double(_margin)}
        set { _margin = CGFloat(newValue)}
    }
    
    
    @IBInspectable var fillColor: UIColor? {
        get { return _color }
        set{ _color = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.beginPath()
        context.move(to: CGPoint(x: rect.minX + _margin, y: rect.maxY - _margin))
        context.addLine(to: CGPoint(x: rect.maxX - _margin, y: rect.maxY - _margin))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY + _margin))
        context.closePath()
        
        context.setFillColor(_color.cgColor)
        context.fillPath()
    }
}
