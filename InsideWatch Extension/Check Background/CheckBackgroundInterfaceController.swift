//
//  CheckBackgroundInterfaceController.swift
//  InsideWatch Extension
//
//  Created by Bianca Itiroko on 27/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class CheckBackgroundInterfaceController: WKInterfaceController, WCSessionDelegate {
    let MY_LEVEL = 3
    let userDefaults = UserDefaults.standard

    @IBOutlet var funfouLabel: WKInterfaceLabel!
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        self.userDefaults.set(false, forKey: "wonBackgroundLevel")
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        let hasWonBackgroundLevel = self.userDefaults.bool(forKey: "wonBackgroundLevel")
        
        if hasWonBackgroundLevel {
            self.wonLevel(level: MY_LEVEL)
            dismiss()
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let message = message["shouldDismiss"] as? Bool{
            if message {
                self.dismiss()
            }
        }
    }
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
