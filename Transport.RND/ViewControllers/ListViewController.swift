//
//  ListTableViewController.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 11.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ListViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var routes: [RoutesText] = [RoutesText]()
    
    var routesByType = [Int: [RoutesText]]()
    
    var city = CitySettings()
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.routesByType[0] = [RoutesText]()
        self.routesByType[1] = [RoutesText]()
        self.routesByType[2] = [RoutesText]()
        self.routesByType[3] = [RoutesText]()
        self.routesByType[4] = [RoutesText]()
        setTable()
    }
    
    func setTable() {
        URLSession.shared.dataTask(with: URL(string: city.route)!) { (data, response, error) in
            if let data = data {
                do {
                    self.routes = try JSONDecoder().decode([RoutesText].self, from: data)
                    for route in self.routes {
                        switch route.getType() {
                        case .bus:
                            self.routesByType[4]?.append(route)
                        case .minibus:
                            self.routesByType[3]?.append(route)
                        case .trolleybus:
                            self.routesByType[2]?.append(route)
                        case .tram:
                            self.routesByType[1]?.append(route)
                        case .meg:
                            self.routesByType[0]?.append(route)
                        default: break
                        }
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMapFromList" {
            let mapView = (segue.destination as! MapViewController)
            let type = sender as? (CarType, String)
            mapView.transportData = TransportData(type: (type?.0)!, route: (type?.1)!)
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
}


extension ListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell") as! CustomTableViewCell

        cell.set(indexPath, city, routesByType) { (indexPath) -> Bool in
            return check(indexPath: indexPath)
        }
        
        cell.isUserInteractionEnabled = true
        cell.forTap.isUserInteractionEnabled = true
        cell.forTap.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:))))
        return cell
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        print("handleTap")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelectRowAt")
        guard let route = self.routesByType[indexPath.section]?[indexPath.row] else { return }
        self.performSegue(withIdentifier: "toMapFromList", sender: (route.getType(), route.number!))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (routesByType[section]?.count)!
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(self.routesByType.count)
        return self.routesByType.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Аэропорт"
        case 1: return "Трамваи"
        case 2: return "Троллейбусы"
        case 3: return "Маршрутки"
        case 4: return "Автобусы"
        default: return ""
        }
    }
    
    func check(indexPath: IndexPath) -> Bool {
        if let data = self.getCoreData() {
            let flag = data.contains { r in
                let routes = self.routesByType[indexPath.section]!
                if r.city! == self.city.city.rawValue && r.route! == routes[indexPath.row].number! && r.type! == routes[indexPath.row].getType().rawValue {
                    return true
                } else {
                    return false
                }
            }
            return flag
        }
        return false
    }
}

