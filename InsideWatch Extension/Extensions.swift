//
//  Extensions.swift
//  InsideWatch Extension
//
//  Created by Bianca Itiroko on 27/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import WatchConnectivity
import Foundation

extension WKInterfaceController {


    /// Gets the current leve won, updates the userDefaults "maxLevelReached" and send a message to iPhone
    ///
    /// - Parameter level: level won
    func wonLevel(level:Int){

        //Update userDefaults: não preciso atualizar o userDefaults
//        userDefaults.set(level + 1, forKey: "maxLevelReached")
        
        //Send iPhone a message
        if(WCSession.default.isReachable){
            let message = ["newWonLevel": level]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
    }
    
    
}
