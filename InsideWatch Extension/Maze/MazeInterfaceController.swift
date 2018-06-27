//
//  InterfaceController.swift
//  MazeGame Extension
//
//  Created by Bianca Itiroko on 18/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import Foundation


class MazeInterfaceController: WKInterfaceController {
    let MY_LEVEL = 1

    @IBOutlet var skInterface: WKInterfaceSKScene!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        // Load the SKScene from 'GameScene.sks'
        if let scene = GameScene(fileNamed: "GameScene") {
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            self.skInterface.presentScene(scene)
            
            // Use a value that will maintain a consistent frame rate
            self.skInterface.preferredFramesPerSecond = 30
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
}
