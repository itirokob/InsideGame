//
//  ViewController.swift
//  InsideGame
//
//  Created by Bianca Itiroko on 21/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {}
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(WCSession.isSupported()){
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    @IBAction func levelAction(_ sender: UIButton) {
        if(WCSession.default.isReachable){
            let message = ["currentLevel": String(sender.tag + 1)]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
        
        performSegue(withIdentifier: "levelSegue", sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("OIEEEE")
    }
    
    //Ao adicionar um novo botão, dar update na tag (ela vai de 0 a n-1)
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "levelSegue" {
            if let destination = segue.destination as? LevelViewController, let sender = sender as? UIButton{
                destination.level = sender.tag
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
