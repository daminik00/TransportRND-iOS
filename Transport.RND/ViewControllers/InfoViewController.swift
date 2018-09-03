//
//  InfoViewController.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 16/06/2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    
    @IBAction func checkCity(_ sender: Any) {
        
        
        let alert = UIAlertController(title: "Выберите город", message: "Функции могут отличаться", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ростов", style: .default, handler: { (action) in
            CitySettings.shared.city = .rostov
            CitySettings.shared.writeToRealm()
        }))
        alert.addAction(UIAlertAction(title: "Краснодар", style: .default, handler: { (action) in
            CitySettings.shared.city = .krasnodar
            CitySettings.shared.writeToRealm()
        }))
        alert.addAction(UIAlertAction(title: "Челябинск", style: .default, handler: { (action) in
            CitySettings.shared.city = .chelyabinsk
            CitySettings.shared.writeToRealm()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
