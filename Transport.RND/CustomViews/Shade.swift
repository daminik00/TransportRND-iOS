//
//  Shape.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 20/06/2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit

enum UIShadePosition {
    case top(CGFloat)
    case bottom(CGFloat)
}

class UIShade: UIView {
    
    var position: UIShadePosition?
    
    init(height: CGFloat, position: UIShadePosition, bounds: CGRect) {
        let screen = bounds
        self.position = position
        var frame = CGRect()
        switch position {
        case .top(let shift):
            frame = CGRect(x: 0, y: 0+shift, width: screen.width, height: height)
            
        case .bottom(let shift):
            frame = CGRect(x: 0, y: screen.height-height-shift, width: screen.width, height: height)
        }
        super.init(frame: bounds)
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        let view = UIShadeView(frame: frame)
        self.addSubview(view)
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.roundCorners(self.position)
    }
    
    func roundCorners() {
        guard let _ = self.position else { return }
        self.clipsToBounds = true
        var corners: UIRectCorner
        switch position! {
        case .top(_):
            corners = [.bottomLeft, .bottomRight]
        case .bottom(_):
            corners = [.topRight, .topLeft]
        }
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 20, height: 20))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class UIShadeView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var viewControl = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 20))
        viewControl.backgroundColor = .black
        self.addSubview(viewControl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func roundCorners(_ position: UIShadePosition?) {
        guard let _ = position else { return }
        self.clipsToBounds = true
        var corners: UIRectCorner
        switch position! {
        case .top(_):
            corners = [.bottomLeft, .bottomRight]
        case .bottom(_):
            corners = [.topRight, .topLeft]
        }
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: 20, height: 20))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}



extension UIView {
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}









