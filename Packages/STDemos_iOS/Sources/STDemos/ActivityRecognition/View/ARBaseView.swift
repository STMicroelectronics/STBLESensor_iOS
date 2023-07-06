//
//  ARBaseView.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import Foundation
import STBlueSDK

protocol ARBaseView{
    var activityToImage:[ActivityType:UIImageView] {get}
    func setVisible()
    func setHidden()
}

private let SELECTED_ALPHA = CGFloat(1.0)
private let DESELECTED_ALPHA = CGFloat(0.3)

extension ARBaseView{
    
    func deselectAll(){
        activityToImage.values.forEach{ deselect($0)}
    }
    
    func select(type:ActivityType){
        print(type)
        if let img = activityToImage[type]{
            select(img)
        }
    }
    
    func deselect(type:ActivityType){
        if let img = activityToImage[type]{
            deselect(img)
        }
    }
    
    private func select(_ image : UIImageView) {
        image.alpha = SELECTED_ALPHA
    }
    
    private func deselect(_ image :UIImageView){
        image.alpha = DESELECTED_ALPHA
    }
    
}

extension UIView{
    func setVisible() {
        isHidden = false
    }
    
    func setHidden() {
        isHidden = true
    }
}
