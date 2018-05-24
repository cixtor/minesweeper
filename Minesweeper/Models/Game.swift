//
//  Game.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import Foundation

enum GameState {
    case new
    case loaded
    case inProgress
    case paused
    case lost
    case win
}

class Game {
    var mineField: MineField
    var state: GameState = .new
    var minesRemaining: Int
    
    var flaggedCellIndices: Set<Int> = []
    
    init(mineField: MineField = MineField()) {
        self.mineField = mineField
        self.minesRemaining = mineField.bombCellIndices.count
    }
}
