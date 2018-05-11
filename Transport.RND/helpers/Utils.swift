//
//  Utils.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 06.05.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation


class Utils {
    
    static func checkPosition(_ lat: Double, lng: Double, delegate: CameraPositionDelegate) -> Bool {
        if delegate.cameraPosition == nil { return true }
        if lat > (delegate.cameraPosition?.bottomLeftLat)! && lat < (delegate.cameraPosition?.topLeftLat)! && lng > (delegate.cameraPosition?.topLeftLng)! && lng < (delegate.cameraPosition?.topRightLng)! {
            return true
        } else { return false }
    }
    
}
