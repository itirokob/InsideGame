
//  MenuScene.swift
//  InsideGame
//
//  Created by Clara Carneiro on 26/06/2018.
//  Copyright © 2018 Clara Carneiro. All rights reserved.
//

import UIKit
import WatchConnectivity
import SpriteKit

//Implementa a função

class MenuScene: SKScene, TreatWatchMessages {
    
    var numberOfLevels = 4
    var hints = [
        "BRING BACK \nMY BALANCE!",
        "I AM FELLING \nLONELY",
        "I AM \nEXHAUSTED",
        "HELP ME! \nI'M DROWNING"
    ]
    
    let userDefaults = UserDefaults.standard

    public var hintLabel = SKLabelNode()
    public var levelButtons = [SKNode]()
    var map = SKTileMapNode()
    var selectedNode = SKNode()
    var stateLevel = ["unsolved", "unsolved", "unsolved", "unsolved"]
    

    let userDefaults = UserDefaults.standard

    func wonLevel(level: Int) {
        //Mudar a texture do levelButton de indice level
        //Habilitar o próximo botão
        let solvedTexture = SKTexture(imageNamed: "maze-solved")
        let setSolved = SKAction.setTexture(solvedTexture)
        (self.levelButtons[level-1] as! SKSpriteNode).run(setSolved)
        self.stateLevel[level-1] = "solved"
        //let changeColor = SKAction.colorize(with: .green, colorBlendFactor: 1.0, duration: 0.15)
        //(self.levelButtons[level-1] as! SKSpriteNode).run(changeColor)
    }

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
            //print ("sou clicável")
            let index = selectedNode.name?.index((selectedNode.name?.startIndex)!, offsetBy: 5)
            let level = Int(String((selectedNode.name?[index!])!))
            //print(level!)
            self.hintLabel.text = hints[Int(String(level!))! - 1]

            let selectedTexture = SKTexture(imageNamed: "maze-selected")
            let deselectedTexture = SKTexture(imageNamed: "maze-\(self.stateLevel[level!-1])")
            let setSelected = SKAction.setTexture(selectedTexture)
            let setDeselected = SKAction.setTexture(deselectedTexture)

            //let changeColorBlue = SKAction.colorize(with: .blue, colorBlendFactor: 1.0, duration: 0.15)
            //let changeColorRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.15)
            for index in 0 ..< (levelButtons.count) { (self.levelButtons[index] as! SKSpriteNode).run(setDeselected) }
            (self.levelButtons[level!-1] as! SKSpriteNode).run(setSelected)
            
            if(WCSession.default.isReachable){
                let message = ["currentLevel": level]
//                let shouldDismissMsg = ["shouldDismiss": true]
//                WCSession.default.sendMessage(shouldDismissMsg, replyHandler: nil)
                WCSession.default.sendMessage(message, replyHandler: nil)
            }
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
