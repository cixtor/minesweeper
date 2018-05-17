//
//  UIColor.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(rgb: UInt, alpha: Double = 1.0) {
        self.init(
            red:    CGFloat((rgb    & 0xFF0000) >> 16) / 255.0,
            green:  CGFloat((rgb    & 0x00FF00) >> 8)  / 255.0,
            blue:   CGFloat( rgb    & 0x0000FF)        / 255.0,
            alpha:  CGFloat(alpha)
        )
    }
}
