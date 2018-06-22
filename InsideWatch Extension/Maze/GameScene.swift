//
//  GameScene.swift
//  MazeGame Extension
//
//  Created by Bianca Itiroko on 18/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import SpriteKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    let manager = CMMotionManager()
    var player = SKSpriteNode()
    var endNode = SKSpriteNode()
    
    override func sceneDidLoad() {
        self.player = self.childNode(withName: "player") as! SKSpriteNode
        self.endNode = self.childNode(withName: "endNode") as! SKSpriteNode
        
        self.physicsWorld.contactDelegate = self
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main){
            (data, error) in
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!) * 10, dy: CGFloat((data?.acceleration.y)!) * 10)
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var bodyA = contact.bodyA
        var bodyB = contact.bodyB
        
        if (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2) || (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 1) {
            print("You won!")
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
