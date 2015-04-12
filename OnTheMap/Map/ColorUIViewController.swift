//
//  ColorUIViewController.swift
//  Map
//
//  Created by Jeffrey Zhang on 4/6/15.
//  Copyright (c) 2015 Jeffrey. All rights reserved.
//

import Foundation
import UIKit

class ColorUIViewController : UIViewController {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init() {
         super.init()
        
        self.view.backgroundColor = UIColor.clearColor()
        let colorTop = UIColor(red: 1.00, green: 0.502, blue: 0.00, alpha: 1.0).CGColor
        let colorBottom = UIColor(red: 0.80, green: 0.4, blue: 0.00, alpha: 1.0).CGColor
        var backgroundGradient: CAGradientLayer = CAGradientLayer()
        backgroundGradient.colors = [colorTop, colorBottom]
        backgroundGradient.locations = [0.0, 1.0]
        backgroundGradient.frame = self.view.frame
        self.view.layer.insertSublayer(backgroundGradient, atIndex: 0)

    }

}