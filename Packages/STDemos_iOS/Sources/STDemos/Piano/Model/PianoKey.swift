//
//  PianoKey.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class PianoKey {
    
    var pressed = false
    var sound: Int8
    
    var centerX: CGFloat = 0
    var centerY: CGFloat = 0
    var width: CGFloat = 0
    var height: CGFloat = 0
    
    var halfWidth: CGFloat {
        width * 0.5
    }
    
    var halfHeight: CGFloat {
        height * 0.5
    }
    
    init(sound: Int8) {
        self.sound = sound
    }
    
    func checkIfContains(currentTouch: CGPoint) -> Bool {
        let x = currentTouch.x
        let y = currentTouch.y
        
        return x > (centerX-halfWidth) && x <= (centerX+halfWidth) && y > (centerY-halfHeight)  && y <= (centerY+halfHeight)
    }
}
