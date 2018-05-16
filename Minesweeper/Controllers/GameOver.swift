//
//  GameOverScene.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import Foundation
import SpriteKit

class GameOver : SKScene {
    init(size: CGSize, won:Bool) {
        super.init(size: size)

        let message = won ? "You Won" : "You Lost"

        let label = SKLabelNode()
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.white
        label.position = CGPoint(x: 0, y: 0)
        self.addChild(label)
    }

    func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameScene(size: size)
        self.view?.presentScene(scene, transition:reveal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
