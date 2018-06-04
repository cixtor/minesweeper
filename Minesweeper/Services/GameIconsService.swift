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
    
    var boomImage: UIImage?
    var brickTileImage: UIImage?
    var darkGrassImage: UIImage?
    var lightGrassImage: UIImage?
    
    fileprivate init() {
        self.darkGrassImage = UIImage(named: Constants.darkGrassIconName)
        self.lightGrassImage = UIImage(named: Constants.lightGrassIconName)
    }
}
