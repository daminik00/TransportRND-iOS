//
//  CustomTableViewCell.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 19.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit
import CoreData
import TemporaryAlert

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var route: UILabel!
    @IBOutlet weak var type: UIView!
    @IBOutlet weak var disc: UITextView!
    @IBOutlet weak var switchStar: UISwitch!
    @IBOutlet weak var forTap: UIView!
    
    
    var context: NSManagedObjectContext!
    var typeData: CarType?
    var city = City.rostov
    
    override func awakeFromNib() {
        super.awakeFromNib()
        type.layer.cornerRadius = 2
        self.context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        switchStar.isOn = false
    }
    
    func set(_ indexPath: IndexPath, _ city: CitySettings, _ routesByType: [Int: [RoutesText]], check: (IndexPath) -> Bool) {
        self.city = city.city
        var routes = routesByType[indexPath.section]!
        self.route.textColor = .white
        self.route.text = String(routes[indexPath.row].number!)
        if String(routes[indexPath.row].number!).count > 3 {
            self.route.font = UIFont.systemFont(ofSize: 10, weight: .light)
        }
        self.disc.text =  String(routes[indexPath.row].dis!)
        self.type.backgroundColor = Car.getInfo(type: routes[indexPath.row].getType()).color
        self.switchStar.onTintColor = Car.getInfo(type: routes[indexPath.row].getType()).color
        self.typeData = routes[indexPath.row].getType()
        self.switchStar.isOn = check(indexPath)
    }
    
    func check() {
        if let data = self.getCoreData() {
            for d in data {
                print(d.route!, d.type!, d.city!)
            }
            let flag = data.contains { r in
                if r.city! == city.rawValue && r.route! == self.route.text! && r.type! == self.typeData?.rawValue {
                    print("Check", self.route.text!)
                    return true
                } else {
                    return false
                }
            }
            if flag {
                switchStar.isOn = true
            }
        }
    }
    
    
    @IBAction func saveRoute(_ sender: Any) {
        if self.switchStar.isOn {
            do {
                if let data = self.getCoreData() {
                    let flag = data.contains { r in
                        print(self.route.text!)
                        if r.city! == city.rawValue && r.route! == self.route.text! && r.type! == self.typeData?.rawValue {
                            return true
                        } else {
                            return false
                        }
                    }
                    if flag == false {
                        let routeData = SavedRoutes(context: self.context)
                        routeData.city = city.rawValue
                        routeData.route = self.route.text!
                        routeData.type = typeData?.rawValue
                        try self.context.save()
                        TemporaryAlert.show(image: TemporaryAlert.AlertImage.checkmark, title: "Добавленно в избранное", message: nil)
                    }
                } else {
                    let routeData = SavedRoutes(context: self.context)
                    routeData.city = city.rawValue
                    routeData.route = self.route.text!
                    routeData.type = typeData?.rawValue
                    try self.context.save()
                    TemporaryAlert.show(image: TemporaryAlert.AlertImage.checkmark, title: "Добавленно в избранное", message: nil)
                }
            } catch {
                print(error.localizedDescription)
            }
        } else {
            if let data = getCoreData() {
                for r in data {
                    if r.city! == city.rawValue && r.route! == self.route.text! && r.type! == self.typeData?.rawValue {
                        self.context.delete(r)
                        TemporaryAlert.show(image: TemporaryAlert.AlertImage.cross, title: "Удалено из избранного", message: nil)
                    }
                }
            }
        }
    }
    
    func getCoreData() -> [SavedRoutes]? {
        do {
            let fetchRequest: NSFetchRequest<SavedRoutes> = SavedRoutes.fetchRequest()
            let savedRoutes = try self.context.fetch(fetchRequest)
            if savedRoutes.count > 0 {
                return savedRoutes
            } else {
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

