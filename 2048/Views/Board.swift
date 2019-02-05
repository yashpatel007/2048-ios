//
//  Board.swift
//  2048
//
//  Created by Yash Patel on 2/5/19.
//  Copyright © 2019 Yash Patel. All rights reserved.
//

import UIKit

class Tile:UIView{
    var delegate:AppearanceProtocol
    var value:Int=0{
        didSet{
            backgroundColor=deligate.tileColor(value)
            numberLable.textColor=delegate.numberColor(value)
            numberLabel.text="\(value)"
        }
        
    }
    var numberKable:UILabel
    required init?(coder aDecoder: NSCoder) {
        init (coder: NSCoder){
            fatalError("NS coding is not Supported")
        }
        init(position: CGPoint,width: CGFloat, value:Int,radius :CGFloat,delegate d: AppearanceProtocol){
            addSubview(numberLable)
            layer.cornerRadius=radius
            
            self.value=value
            backgroundColor=delegate.tileColor(value)
            numberLabel.textColor=deligate.numberColor(value)
            numberLabel.text="\(value)"
            
        }
    }
}
