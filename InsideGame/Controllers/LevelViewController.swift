//
//  LevelViewController.swift
//  InsideGame
//
//  Created by Bianca Itiroko on 21/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import UIKit
import WatchConnectivity

class LevelViewController: UIViewController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    
    var level:Int?
    var hints = [
        "Hint level 1",
        "Hint level 2",
        "Hint level 3",
        "Hint level 4"
    ]
    @IBOutlet weak var hintLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(WCSession.isSupported()){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        DispatchQueue.main.async {
            self.hintLabel.text = self.getHint()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if(WCSession.default.isReachable){
            let message = ["shouldDismiss": true]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
    }
    func getHint() -> String{
        if let level = self.level {
            return hints[level]
        }
        return "Problemas no level"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
