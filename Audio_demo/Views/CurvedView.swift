//
//  CurvedView.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 12/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import UIKit

class CurvedView: UIView {
override func draw(_ rect: CGRect) {
    super.draw(rect)
    
    let rectShape = CAShapeLayer()
    rectShape.bounds = self.frame
    rectShape.position = self.center
    rectShape.path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.bottomLeft , .bottomRight, .topLeft, .topRight], cornerRadii: CGSize(width: 5, height: 5)).cgPath

    self.layer.mask = rectShape
    }
}
