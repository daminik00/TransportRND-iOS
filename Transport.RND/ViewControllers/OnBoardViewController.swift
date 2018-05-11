//
//  OnBoardViewController.swift
//  Transport.RND
//
//  Created by Даниил Чемеркин on 08.05.2018.
//  Copyright © 2018 daminik00.dev. All rights reserved.
//

import UIKit
import ChameleonFramework

class OnBoardViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let swiftyOnboard = SwiftyOnboard(frame: view.frame)
        view.addSubview(swiftyOnboard)
        swiftyOnboard.dataSource = self
        swiftyOnboard.delegate = self
        swiftyOnboard.fadePages = false
    }
}


extension OnBoardViewController: SwiftyOnboardDataSource {
    
    func swiftyOnboardBackgroundColorFor(_ swiftyOnboard: SwiftyOnboard, atIndex index: Int) -> UIColor? {
//        switch index {
//        case 0:
//            return FlatNavyBlue()
//        case 1:
//            return FlatNavyBlueDark()
//        case 2:
//            return FlatRed()
//        default:
//            return FlatWhite()
//        }
        return nil
    }
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 3
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        let page = SwiftyOnboardPage()
        page.imageView = UIImageView()
        page.imageView.loadGif(name: "onFav")
        page.imageView.animationDuration = 0.1
        page.imageView.contentMode = .scaleAspectFit
        page.subTitle.text = "Hello"
        page.setUp()
        return page
    }
}

extension OnBoardViewController: SwiftyOnboardDelegate {
    func swiftyOnboard(_ swiftyOnboard: SwiftyOnboard, currentPage index: Int) {
        print("currentPage", index)
    }
    func swiftyOnboard(_ swiftyOnboard: SwiftyOnboard, leftEdge position: Double) {
        print("leftEdge", position)
    }
    func swiftyOnboard(_ swiftyOnboard: SwiftyOnboard, tapped index: Int) {
        print("tapped", index)
    }
}
