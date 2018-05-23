//
//  Cell.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import Foundation

enum CellState {
    case untouched
    case revealed
    case flagged
    case exploded
    
    case highlight
    case showBomb
    case wrongBomb
}

class Cell {
    var state: CellState = .untouched
    
    var adjacentCellIndices: Set<Int> = []
    var connectedEmptyCluster: Set<Int> = []
    
    var hasBomb: Bool = false
    var adjacentBombs: Int = 0
    var isEmpty: Bool {
        return self.adjacentBombs == 0
    }
    
    private(set) var index: Int
    private(set) var fieldCoord: FieldCoord = FieldCoord(row: 0, column: 0)
    
    init(index: Int = 0, row: Int = 0, column: Int = 0) {
        self.index = index
        self.fieldCoord = FieldCoord(row: row, column: column)
    }
}
