//
//  StopsControll.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 15.04.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import Foundation

class Stop {
    
    var ids: (a: Int, b: Int) = (a: 0, b: 0)
    
    public static func getStops(by id: Int) {
        var ids = (a: id, b: id+1)
        var handler: (Int, Int) {
            get {
                return (0,0)
            }
            set(data) {
                
            }
        }
        
//        URLSession.shared.dataTask(with: URL(string: "https://google.ru")!) { (data, response, error) in
//            guard let _ = data else { return }
//            handler = ()
//        }
        
    }
    
}
