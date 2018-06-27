//
//  MenuScene.swift
//  InsideGame
//
//  Created by Clara Carneiro on 26/06/2018.
//  Copyright © 2018 Clara Carneiro. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {

    var numberOfLevels = 4
    var hints = [
        "I AM FELLING \nLONELY",
        "I AM \nEXHAUSTED",
        "BRING BACK \nMY BALANCE!",
        "HELP ME! \nI'M DROWNING"
    ]

    public var hintLabel = SKLabelNode()
    public var levelButtons = [SKNode]()
    var map = SKTileMapNode()
    var selectedNode = SKNode()

    override func didMove(to view: SKView) {
        /* Setup your scene here */
        self.map = self.childNode(withName: "Tile Map Node") as! SKTileMapNode
        self.hintLabel = map.childNode(withName: "hintLabel") as! SKLabelNode
        for i in 0 ..< numberOfLevels {
            if let button = map.childNode(withName: "level\(i)") {
                self.levelButtons.append(button)
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchSet = touches as NSSet
        let touch = touchSet.anyObject() as! UITouch
        let positionInScene = touch.location(in: self)

        selectNodeForTouch(positionInScene)

        if selectedNode.name?.range(of: "level") != nil {
            print ("sou clicável")
            let index = selectedNode.name?.index((selectedNode.name?.startIndex)!, offsetBy: 5)
            let level = selectedNode.name?[index!]
            print(level!)
            self.hintLabel.text = hints[Int(String(level!))! - 1]
        }
    }

    func selectNodeForTouch(_ touchLocation: CGPoint) {
        let touchedNode = self.atPoint(touchLocation)
        selectedNode = touchedNode
    }

    func panForTranslation(translation: CGPoint) {
        let position = selectedNode.position

        if selectedNode.name == "Tile Map Node" {
            selectedNode.position = CGPoint(x: position.x + translation.x, y: position.y + translation.y)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchSet = touches as NSSet
        let touch = touchSet.anyObject() as! UITouch
        let positionInScene = touch.location(in: self)
        let previousPosition = touch.previousLocation(in: self)
        let translation = CGPoint(x: positionInScene.x - previousPosition.x, y: positionInScene.y - previousPosition.y)

        panForTranslation(translation: translation)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
}
