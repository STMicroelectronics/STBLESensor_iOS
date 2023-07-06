//
//  BaseAudioClassView.swift
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

protocol BaseAudioClassView{
    var activityToImage:[AudioClass:UIImageView] {get}
    func setVisible()
    func setHidden()
}

private let SELECTED_ALPHA = CGFloat(1.0)
private let DESELECTED_ALPHA = CGFloat(0.3)

extension BaseAudioClassView{
    
    func deselectAll(){
        activityToImage.values.forEach{ deselect($0)}
    }
    
    func select(type:AudioClass) {
        if let img = activityToImage[type] {
            select(img)
        }
    }
    
    func deselect(type:AudioClass) {
        if let img = activityToImage[type] {
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
