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


    /// Gets the current leve won and sends a message to iPhone
    ///
    /// - Parameter level: level won
    func wonLevel(level:Int){
        WKInterfaceDevice.current().play(.click)
        self.dismiss()
        
        //Send iPhone a message
        if(WCSession.default.isReachable){
            let message = ["newWonLevel": level]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
    }
    
    
}
