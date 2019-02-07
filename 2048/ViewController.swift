//
//  ViewController.swift
//  2048
//
//  Created by Yash Patel on 2/2/19.
//  Copyright © 2019 Yash Patel. All rights reserved.


import UIKit

class ViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }


    @IBAction func startGameButtonTapped(_ sender : UIButton){
        let game = GameViewController(dimention: 4, threshold: 2048)
        self.present(game, animated: true, completion: nil)
    }
    
    

}

