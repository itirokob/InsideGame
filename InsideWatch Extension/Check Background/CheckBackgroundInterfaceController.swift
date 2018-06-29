//
//  CheckBackgroundInterfaceController.swift
//  InsideWatch Extension
//
//  Created by Bianca Itiroko on 27/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import WatchKit
import Foundation

class CheckBackgroundInterfaceController: WKInterfaceController {
    let MY_LEVEL = 3
    let userDefaults = UserDefaults.standard

    @IBOutlet var funfouLabel: WKInterfaceLabel!

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
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
