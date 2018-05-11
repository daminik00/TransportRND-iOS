//
//  CatTableViewCell.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 21.03.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit

class CatTableViewCell: UITableViewCell {

    @IBOutlet weak var label: UIView!
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var imageType: UIImageView!
    
    var type: CarType?
    
    func set(_ indexPath: IndexPath, _ city: CitySettings, _ counts: [String: Int]?) {
        self.name.isUserInteractionEnabled = false
        self.name.font = UIFont.systemFont(ofSize: 20, weight: .light)
        let info = Car.getInfo(type: city.type[indexPath.row])
        type = city.type[indexPath.row]
        var string =  "\(info.nameRuS)"
        if counts != nil {
            if let count = counts![city.type[indexPath.row].rawValue] {
                string += ": \(count)"
            }
        }
        if let image = info.image {
            let imageColor = image.withRenderingMode(.alwaysTemplate)
            self.imageType.image = imageColor
            self.imageType.tintColor = info.color
        } else {
            self.label.backgroundColor = info.color
        }
        self.name.text = string
        self.name.textColor = info.color
        self.setSelected(false, animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.layer.cornerRadius = 2
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
