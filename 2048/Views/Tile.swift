//
//  Tile.swift
//  2048
//
//  Created by Yash Patel on 2/5/19.
//  Copyright © 2019 Yash Patel. All rights reserved.
//


import UIKit

/// A view representing a single swift-2048 tile.
class Tile : UIView {
    var value : Int = 0 {
        didSet {
            backgroundColor = delegate.tileColor(value)
            numberLabel.textColor = delegate.numberColor(value)
            numberLabel.text = "\(value)"
        }
    }
    
    unowned let delegate : AppearanceProviderProtocol
    let numberLabel : UILabel
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    init(position: CGPoint, width: CGFloat, value: Int, radius: CGFloat, delegate d: AppearanceProviderProtocol) {
        delegate = d
        numberLabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: width))
        numberLabel.textAlignment = NSTextAlignment.center
        numberLabel.minimumScaleFactor = 0.5
        numberLabel.font = delegate.fontForNumbers()
        
        super.init(frame: CGRect(x: position.x, y: position.y, width: width, height: width))
        addSubview(numberLabel)
        layer.cornerRadius = radius
        
        self.value = value
        backgroundColor = delegate.tileColor(value)
        numberLabel.textColor = delegate.numberColor(value)
        numberLabel.text = "\(value)"
    }
}
