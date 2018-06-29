//
//  MenuViewController.swift
//  InsideGame
//
//  Created by Clara Carneiro on 26/06/2018.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import UIKit
import SpriteKit
import WatchConnectivity

//Chama a função

protocol TreatWatchMessages {
    func wonLevel(level:Int)
}

class MenuViewController: UIViewController, WCSessionDelegate{
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) {}
    
    @IBOutlet var scrollview: UIScrollView!
    @IBOutlet var menuScene: SKView!

    let userDefaults = UserDefaults.standard
    
    var delegate: TreatWatchMessages?
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        // Do any additional setup after loading the view.
        // Register custom font
        if let fontURL = Bundle.main.url(forResource: "SFCompactText-Medium", withExtension: "otf") {
            CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)
        } else {
            print("FontURL is not valid")
        }
        // Load the SKScene from 'GameScene.sks'
        if let scene = SKScene(fileNamed: "Menu") {

            // Set the scale mode to scale to fit the window
            //scene.scaleMode = .aspectFill

            // Present the scene
            self.menuScene.presentScene(scene)
            print("Olar Mapa")

            // Use a value that will maintain a consistent frame rate
            self.menuScene.preferredFramesPerSecond = 30
        }
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


    ///O Watch nos enviará uma mensagem ["newWonLevel" : númeroDaFase], logo, o conteúdo dessa mensagem será a fase (de 1 a 4)
    ///Salvaremos no userDefaults: [levelX: true/false]
    ///
    /// - Parameters:
    ///   - session: WCSession
    ///   - message: ["newWonLevel" : númeroDaFase]
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let message = message["newWonLevel"] as? Int {
            self.userDefaults.set(true, forKey: "level\(message)")
            
            DispatchQueue.main.async {
                self.delegate?.wonLevel(level: message)
            }
        }
    }

}
