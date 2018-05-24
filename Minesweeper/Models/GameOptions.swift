//
//  GameOptions.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import Foundation

struct GameOptions: Codable {
    var rowCount: Int
    var columnCount: Int
    var minesCount: Int
    
    init(rowCount: Int = Constants.defaultRows,
         columnCount: Int = Constants.defaultRows,
         minesCount: Int = Constants.defaultMines) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        self.minesCount = minesCount
    }
}
