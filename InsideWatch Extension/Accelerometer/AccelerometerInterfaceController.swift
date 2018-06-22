//
//  HeartbeatInterfaceController.swift
//  InsideWatch Extension
//
//  Created by Bianca Itiroko on 22/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion

class AccelerometerInterfaceController: WKInterfaceController {

    let motionManager = CMMotionManager()
    
    @IBOutlet var accX: WKInterfaceLabel!
    @IBOutlet var accY: WKInterfaceLabel!
    @IBOutlet var accZ: WKInterfaceLabel!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // set sampling rate
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.2
        }
        
        // start getting updates
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let data = data {
                self.outputAccelerationData(acceleration: data.acceleration)
            }
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func outputAccelerationData(acceleration: CMAcceleration) {
        accX?.setText("accX: \(acceleration.x).2fg")
        accY?.setText("accY: \(acceleration.y).2fg")
        accZ?.setText("accZ: \(acceleration.y).2fg")
    }

}
