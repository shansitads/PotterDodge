//
//  PlayerViewController.swift
//  potterdodge
//
//  Created by Shansita on 28/12/19.
//  Copyright © 2019 Shansita Das Sharma. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

    var player:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var harryLabel: UILabel!
    @IBOutlet var malfoyLabel: UILabel!
    @IBOutlet var ronLabel: UILabel!
    
    
    
    @IBAction func harryButton(_ sender: Any) {
        harryLabel.textColor = UIColor.yellow
        malfoyLabel.textColor = UIColor.white
        ronLabel.textColor = UIColor.white
        
        player = "potter"
        UserDefaults.standard.set(player, forKey: "sprite-name")
        
    }
    @IBAction func malfoyButton(_ sender: Any) {
        harryLabel.textColor = UIColor.white
        malfoyLabel.textColor = UIColor.yellow
        ronLabel.textColor = UIColor.white
        
        player = "malfoy"
        UserDefaults.standard.set(player, forKey: "sprite-name")
    }
    @IBAction func ronButton(_ sender: Any) {
        harryLabel.textColor = UIColor.white
        malfoyLabel.textColor = UIColor.white
        ronLabel.textColor = UIColor.yellow
        
        player = "ron"
        UserDefaults.standard.set(player, forKey: "sprite-name")
    }
    
    @IBAction func selectButton(_ sender: Any) {
        
        UserDefaults.standard.synchronize()
    }
    

}
