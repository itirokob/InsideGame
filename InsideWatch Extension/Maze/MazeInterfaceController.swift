//
//  InterfaceController.swift
//  MazeGame Extension
//
//  Created by Bianca Itiroko on 18/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class MazeInterfaceController: WKInterfaceController,WCSessionDelegate, WonMazeLevelDelegate {
    let MY_LEVEL = 1

    @IBOutlet var skInterface: WKInterfaceSKScene!

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

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
            
            scene.wonMazeDelegate = self
        }
    }
    
    func wonMazeLevel() {
        self.wonLevel(level: MY_LEVEL)
        WKInterfaceDevice.current().play(.click)
        self.dismiss()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let message = message["shouldDismiss"] as? Bool{
            if message {
                self.dismiss()
            }
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
