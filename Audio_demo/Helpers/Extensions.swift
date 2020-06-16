//
//  Extensions.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 12/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import UIKit

extension UIView {
    
    func takeScreenshot() -> UIImage {
        
        let view = self
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        //        view.backgroundColor = .clear
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

extension Double {
    
    func hideOneDigit(temp: Double) -> String {
        return String(format: "%g", temp)
    }
    
}

extension Int {
    func secondsToHoursMinutesSeconds () -> (Int, Int, Int) {
        return (self / 3600, (self % 3600) / 60, (self % 3600) % 60)
    }
}

 extension UIView {

    func dropShadow() {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1
        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale

    }
}
