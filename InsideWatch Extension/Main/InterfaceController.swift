//
//  InterfaceController.swift
//  InsideWatch Extension
//
//  Created by Bianca Itiroko on 21/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity
import HealthKit

class InterfaceController: WKInterfaceController, WCSessionDelegate{
    var segueName:String = ""
    @IBOutlet var messageReceived: WKInterfaceLabel!
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let message = message["currentLevel"] as? String{
            self.segueName = "level" + (message) + "Controller"
            
            DispatchQueue.main.async {
                self.presentController(withName: self.segueName, context: nil)
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        // Request HealthKit authorization
        HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in
            guard authorized else {
                
                let baseMessage = "HealthKit Authorization Failed"
                
                if let error = error {
                    print("\(baseMessage). Reason: \(error.localizedDescription)")
                } else {
                    print(baseMessage)
                }
                return
            }
            print("HealthKit Successfully Authorized.")
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
