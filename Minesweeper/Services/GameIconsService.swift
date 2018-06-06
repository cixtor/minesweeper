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
    var fieldTileImage: UIImage?
    
    fileprivate init() {
        self.brickTileImage = UIImage(named: Constants.brickTileIconName)
        self.fieldTileImage = UIImage(named: Constants.fieldTileIconName)
    }
}
