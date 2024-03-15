//
//  FirmwareViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import STDemos

public class FirmwareViewModel: BaseCellViewModel<Firmware, FirmwareCell> {

    public override func configure(view: FirmwareCell) {

        TextLayout.title2.apply(to: view.titleLabel)
        TextLayout.text.apply(to: view.versionLabel)
        TextLayout.info.apply(to: view.changelogLabel)
        TextLayout.info.apply(to: view.availableDemosLabel)

        guard let param = param else { return }

        view.titleLabel.text = param.name
        view.versionLabel.text = param.version
        if let maturity = param.maturity {
            if maturity != Maturity.release {
                view.maturityLabel.isHidden = false
                view.maturityLabel.text = param.maturity?.description
            }
        }
        view.changelogLabel.text = param.description ?? "--"
        view.availableDemosLabel.text = param.availableDemosString
    }
}


public extension Firmware {
    var availableDemos: [Demo]? {
        
        var uuidsString: [String] = []
        self.characteristics?.forEach { characteristic in
            uuidsString.append(characteristic.uuid)
        }
        
        let fTypes = FeatureType.featureClasses(from: uuidsString)
        let demos = Demo.demos(withFeatureTypes: fTypes)
        
        return demos
    }
    
    var availableDemosString: String {
        var stringDemos = ""
        self.availableDemos?.forEach{ demo in
            if(stringDemos != ""){
                stringDemos.append(", ")
            }
            stringDemos.append("\(demo.title)")
        }
        return stringDemos
    }
}
