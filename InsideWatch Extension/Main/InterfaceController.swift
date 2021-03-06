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
    
    
    /// Called when a level is selected in iPhone and present the correspondent controller
    ///
    /// - Parameters:
    ///   - session: WCSession between watch and iOS
    ///   - message: which level should watch presents
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let message = message["currentLevel"] as? Int{
            self.segueName = "level" + String(message) + "Controller"

            DispatchQueue.main.async {
                self.dismiss()
                self.presentController(withName: self.segueName, context: nil)
            }
        }
    }
    
    ///This method is called when watch view controller is about to be visible to user
    override func willActivate() {
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
        super.didDeactivate()
    }
}
