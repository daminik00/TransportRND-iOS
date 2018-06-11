//
//  TypeTableViewController.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 13.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit
import CoreData
import Appodeal
import CoreLocation
import Onboard

class TypeViewController: UIViewController, AppodealInterstitialDelegate, AppodealBannerDelegate {
    
    @IBOutlet weak var tabeView: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    var city = CitySettings()
    var context: NSManagedObjectContext!
    
    var types: [CarType] = [.bus, .minibus, .tram, .trolleybus, .meg, .all]
    var counts: [String: Int]?
    var callHeight: CGFloat = 55
    
    override func viewDidLoad() {
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        self.context = ((UIApplication.shared.delegate) as! AppDelegate).persistentContainer.viewContext
        tabeView.delegate = self
        tabeView.dataSource = self
        super.viewDidLoad()
        self.tabeView.addSubview(refreshControl)
        getData(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getData(false)
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(TypeViewController.updateData(_:)), for: .valueChanged)
        refreshControl.tintColor = .black
        return refreshControl
    }()
    
    func goToMap(type: CarType) {
        self.performSegue(withIdentifier: "toMap", sender: type)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap" {
            let mapView = (segue.destination as! MapViewController)
            mapView.transportData = TransportData(type: (sender as! CarType))
        }
    }
    
    func getCoreData() -> [SavedRoutes]? {
        do {
            let fetchRequest: NSFetchRequest<SavedRoutes> = SavedRoutes.fetchRequest()
            let savedRoutes = try self.context.fetch(fetchRequest)
            if savedRoutes.count > 0 {
                var routes = [SavedRoutes]()
                for i in savedRoutes {
                    if i.city! == city.city.rawValue {
                        routes.append(i)
                    }
                }
                if routes.count == 0 {
                    return nil
                } else {
                    return routes
                }
            } else {
                return nil
            }
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}



extension TypeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.city.type.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "catCell") as! CatTableViewCell
        cell.set(indexPath, city, counts)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.goToMap(type: city.type[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return callHeight
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
}


extension TypeViewController {
    
    @objc func updateData(_ refreshControl: UIRefreshControl) {
        getData(true)
        refreshControl.endRefreshing()
    }
    
    @IBAction func editTap(_ sender: UIBarButtonItem) {
        switch sender.title {
        case "Edit":
            tabeView.setEditing(true, animated: true)
            editButton.title = "Done"
        case "Done":
            var types = [String]()
            for i in 0..<(self.counts?.count)! {
                let cell = tabeView.cellForRow(at: IndexPath(row: i, section: 0)) as! CatTableViewCell
                if (cell.type?.rawValue)! == "favorites" {
                    UserDefaults.standard.set(i, forKey: "favIndex")
                } else {
                    types.append((cell.type?.rawValue)!)
                }
            }
            UserDefaults.standard.setValue(types, forKey: "catArray")
            editButton.title = "Edit"
            tabeView.setEditing(false, animated: true)
        default:
            break
        }
        
    }
    
    
    fileprivate func getData(_ count: Bool) {
        var index = 0
        if let array = UserDefaults.standard.value(forKey: "catArray") {
            if let arrayTypes = array as? [String] {
                city.types[city.city] = [CarType]()
                for type in arrayTypes {
                    city.types[city.city]?.append(CarType(rawValue: type)!)
                }
            }
        }
        if let _index = UserDefaults.standard.value(forKey: "favIndex") {
            if let __index = _index as? Int {
                index = __index
            }
        }
        var types = self.city.types[city.city]!
        if let _ = self.getCoreData() {
            print("Data get")
            if types[0] != CarType.fav {
                self.city.types[city.city]?.insert(.fav, at: index)
            }
        } else {
            if types[0] == CarType.fav {
                self.city.types[city.city]!.remove(at: index)
            }
        }
        if let data = self.getCoreData() {
            if let _ = self.counts {
                self.counts!["favorites"] = data.count
            } else {
                self.counts = [
                    "favorites": data.count
                ]
            }
        }
        if city.city == .rostov && count {
            DispatchQueue.global(qos: .background).async {
                do {
                    let count = try String(contentsOf: URL(string: "http://api.daminik00.ru/methods/getRndTransport.php")!)
                    let countArray = count.components(separatedBy: ";")
                    if let _ = Int(countArray[0]) {
                        var counts = [String: Int]()
                        
                        if self.counts != nil {
                            if self.counts!["favorites"] != nil && self.counts!["favorites"] != 0 {
                                counts["favorites"] = self.counts!["favorites"]
                            }
                        }
                        
                        counts["bus"] = Int(countArray[0])!
                        counts["minibus"] = Int(countArray[1])!
                        counts["tram"] = Int(countArray[2])!
                        counts["trolleybus"] = Int(countArray[3])!
                        counts["meg"] = Int(countArray[4])!
                        counts["all"] = Int(countArray[0])!+Int(countArray[1])!+Int(countArray[2])!+Int(countArray[3])!+Int(countArray[4])!
                        self.counts = counts
                        print(counts)
                    }
                    DispatchQueue.main.async {
                        self.tabeView.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        self.tabeView.reloadData()
    }
}

