//
//  Accessory.swift
//  2048
//
//  Created by Yash Patel on 2/5/19.
//  Copyright © 2019 Yash Patel. All rights reserved.
//


import UIKit

protocol ScoreViewProtocol{
    func scoreChanged(newScore s:Int)
}

class ScoreView : UIView, ScoreViewProtocol{
    var score: Int = 0{
        didSet{
            label.text="SCORE:\(score)"
            
        }
    }
    
    let defaultFrame = CGRect(x: 0,y: 0,width: 140,height: 140)
    var label :UILabel
    
    init(backgroundColor bgcolor: UIColor,textColor tcolor: UIColor, font :UIFont,radius r: CGFloat){
        label = UILabel(frame: defaultFrame)
        label.textAlignment = NSTextAlignment.center
        super.init(frame: defaultFrame)
        backgroundColor = bgcolor
        label.textColor = tcolor
        label.font = font
        layer.cornerRadius = r
        self.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("NS coading Not Supported")
    }
    
    func scoreChanged(newScore s: Int) {
        score = s
    }
    
    class ControlView {
        let defaultFrame = CGRect(x: 0, y: 0, width: 140, height: 40)
        
    }
    
}
