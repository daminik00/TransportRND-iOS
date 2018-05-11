//
//  AllRoutes.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 17.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation
struct AllRoutes : Codable {
    let id : Int?
    let number : String?
    let transport : String?
    
    func getType() -> CarType {
        switch transport! {
        case "bus":
            return .bus
        case "minibus":
            return .minibus
        case "trol":
            return .trolleybus
        case "tram":
            return .tram
        case "suburbanbus":
            return .meg
        default:
            return .bus
        }
    }
    
}

struct Stops : Codable {
    let id : Int?
    let number : String?
    let lat : Double?
    let lng : Double?
}
