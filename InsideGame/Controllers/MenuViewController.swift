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

class MenuViewController: UIViewController {

    @IBOutlet var scrollview: UIScrollView!
    @IBOutlet var menuScene: SKView!

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
