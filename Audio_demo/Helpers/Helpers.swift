//
//  Helpers.swift
//  Audio_demo
//
//  Created by Margarita Blanc on 11/06/2020.
//  Copyright © 2020 Frederic Blanc. All rights reserved.
//

import Foundation
import UIKit

func tempi_dispatch_main(closure:@escaping ()->()) {
    DispatchQueue.main.async {
        closure()
    }
}

func tempi_dispatch_delay(delay:Double, closure:@escaping ()->()) {
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
        closure()
    }
}

func tempi_round_device_scale(d: CGFloat) -> CGFloat
{
    let scale: CGFloat = UIScreen.main.scale
    return round(d * scale) / scale
}
