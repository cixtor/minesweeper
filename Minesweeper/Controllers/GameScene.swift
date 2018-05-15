//
//  GameScene.swift
//  Minesweeper
//
//  Created by Yorman on 6/15/18.
//  Copyright © 2018 yorman. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let None:  UInt32 = 0
    static let All:   UInt32 = UInt32.max
    static let Touch: UInt32 = 0b1
    static let Field: UInt32 = 0b10
}

struct tile : Hashable {
    var description:String {
        return "posX\(x)Y\(y)"
    }

    var hashValue:Int {
        return x + (y * 100)
    }

    var x : Int
    var y : Int
}

func == (lhs: tile, rhs: tile) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var nodes = [SKSpriteNode]()
    var touchNode = SKSpriteNode()
    var gameLogic = Gamelogic()

    override func didMove(to: SKView) {
        physicsWorld.gravity = CGVector.init(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self

        let title = SKLabelNode()
        title.text = "Minesweeper";
        title.fontSize = 26;
        title.position = CGPoint(x: size.width/2, y: size.height-150);
        self.addChild(title)

        self.addFields()

        for y in 0...8{
            for x in 0...8{
                gameLogic.initField(x: x, y: y, mine: false)
            }
        }

        gameLogic.initField(x: 3, y: 2, mine: true)
        gameLogic.initField(x: 4, y: 2, mine: true)
        gameLogic.initField(x: 5, y: 2, mine: true)
        gameLogic.initField(x: 3, y: 4, mine: true)
        gameLogic.initField(x: 4, y: 5, mine: true)
    }

    func addFields(){
        let startPosition = CGPoint(x: 350, y: 550)

        for y in 0...8{
            for x in 0...8{
                let t1 = CGFloat(x * 40)
                let t2 = CGFloat(y * 40)
                let field = SKSpriteNode(color: SKColor.black, size: CGSize(width: 30, height: 30))
                field.position = CGPoint(x: startPosition.x + t1, y: startPosition.y - t2)
                field.name = NSString(format: "%i:%i", x, y) as String

                field.physicsBody = SKPhysicsBody(rectangleOf: field.size)
                field.physicsBody?.isDynamic = true
                field.physicsBody?.categoryBitMask = PhysicsCategory.Field
                field.physicsBody?.contactTestBitMask = PhysicsCategory.Touch
                field.physicsBody?.collisionBitMask = PhysicsCategory.None

                nodes.append(field)
                self.addChild(field)
            }
        }
    }

    func reloadField(node : SKNode){
        let name = node.name!
        var nameArr = name.components(separatedBy: ":")
        let x = Int(nameArr[0])
        let y = Int(nameArr[1])

        if (gameLogic.islooser(x: x!, y: y!)) {
            let gameoverscene = GameOver(size: self.size, won: false)
            self.view?.presentScene(gameoverscene)
            return
        }

        if (gameLogic.isClicked(x: x!, y: y!) == false) {
            let number = gameLogic.countNeighbourMines(x: x!,y: y!)
            let label = SKLabelNode(fontNamed:"Courier")
            label.text = String(number);
            label.fontSize = 20;
            label.position = CGPoint(x: node.position.x, y: node.position.y-10)
            self.addChild(label)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let touchLocation = touch.location(in: self)

            touchNode = SKSpriteNode(color: SKColor.yellow, size: CGSize(width: 5  , height: 5))
            touchNode.position = touchLocation
            touchNode.name = "touch"

            touchNode.physicsBody = SKPhysicsBody(rectangleOf: touchNode.size)
            touchNode.physicsBody?.isDynamic = true
            touchNode.physicsBody?.categoryBitMask = PhysicsCategory.Touch
            touchNode.physicsBody?.contactTestBitMask = PhysicsCategory.Field
            touchNode.physicsBody?.collisionBitMask = PhysicsCategory.None

            nodes.append(touchNode)
            addChild(touchNode)
        }
    }

    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }

    func didBegin(_ contact: SKPhysicsContact) {
        print("contact")

        //let tempNode = SKPhysicsBody()

        if (contact.bodyA.categoryBitMask == PhysicsCategory.Field) {
            let temp = contact.bodyA.node
            reloadField(node: temp!)
            //var tempNode = contact.bodyA
        }

        if (contact.bodyB.categoryBitMask == PhysicsCategory.Field) {
            let temp = contact.bodyB.node
            reloadField(node: temp!)
            //var tempNode = contact.bodyB
        }

        //reloadField(tempNode)
    }
}
