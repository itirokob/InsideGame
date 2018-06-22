//
//  LevelViewController.swift
//  InsideGame
//
//  Created by Bianca Itiroko on 21/06/18.
//  Copyright © 2018 Bianca Itiroko. All rights reserved.
//

import UIKit

class LevelViewController: UIViewController {
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
        
        DispatchQueue.main.async {
            self.hintLabel.text = self.getHint()
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
