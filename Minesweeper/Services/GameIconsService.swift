//
//  GameIconsService.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import Foundation
import UIKit

class GameIconsService {
    static let shared = GameIconsService()
    
    var brickTileImage: UIImage?
    var darkGrassImage: UIImage?
    var lightGrassImage: UIImage?
    var flagImage: UIImage?
    var shovelImage: UIImage?
    var boomImage: UIImage?
    var bombImage: UIImage?
    var gearImage: UIImage?
    var xImage: UIImage?
    
    fileprivate init() {
        self.brickTileImage = UIImage(named: Constants.brickTileIconName)
        self.darkGrassImage = UIImage(named: Constants.darkGrassIconName)
        self.lightGrassImage = UIImage(named: Constants.lightGrassIconName)
        self.flagImage = UIImage(named: Constants.flagIconName)
        self.shovelImage = UIImage(named: Constants.shovelIconName)
        self.boomImage = UIImage(named: Constants.boomIconName)
        self.bombImage = UIImage(named: Constants.bombIconName)
        self.gearImage = UIImage(named: Constants.gearIconName)
        self.xImage = UIImage(named: Constants.xIconName)
    }
}