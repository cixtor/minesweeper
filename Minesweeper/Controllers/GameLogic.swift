//
//  Gamelogic.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import Foundation
import UIKit

enum status {
    case CLICKED
    case UNCLICKED
}

struct field :  Hashable {
    var description:String {
        return "posX\(x)Y\(y)"
    }

    var hashValue:Int {
        return x + (y * 100)
    }

    var x : Int
    var y : Int
}

func == (lhs: field, rhs: field) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

let NEIGHBOUR : [CGPoint] = [
    CGPoint(x: -1, y: -1),
    CGPoint(x: -1, y:  0),
    CGPoint(x: -1, y:  1),
    CGPoint(x:  0, y: -1),
    CGPoint(x:  0, y:  1),
    CGPoint(x:  1, y: -1),
    CGPoint(x:  1, y:  0),
    CGPoint(x:  1, y:  1)
]

class Gamelogic {
    var allFields = [field : status]()
    var mines = [field : Int]()

    func initField(x: Int, y : Int, mine : Bool){
        if (mine) {
            allFields[field(x: x, y: y)] = status.UNCLICKED
            addMine(x: x, y: y)
        } else {
            allFields[field(x: x, y: y)] = status.UNCLICKED
        }
    }

    func addMine(x: Int, y : Int){
        mines[field(x: x, y: y)] = 1
    }

    func mineExists(x : Int, y : Int) -> Bool{
        return (( mines.index(forKey: field(x: x, y: y)) ) != nil)
    }

    func countNeighbourMines(x: Int, y : Int) -> Int{
        var count = 0

        for i in 0...NEIGHBOUR.count - 1 {
            if (mineExists( x: x + Int(NEIGHBOUR[i].x), y: y + Int(NEIGHBOUR[i].y))) {
                count += 1
            }
        }

        doClick(x: x, y: y)

        return count
    }

    func islooser(x: Int, y : Int) -> Bool{
        return (mines[field(x: x, y: y)] != nil)
    }

    func doClick(x: Int, y : Int){
        allFields[field(x: x, y: y)] = status.CLICKED
    }

    func isClicked(x: Int, y : Int) -> Bool {
        let tempField = field(x: x, y: y)
        return (allFields[tempField] == status.CLICKED)
    }
}
