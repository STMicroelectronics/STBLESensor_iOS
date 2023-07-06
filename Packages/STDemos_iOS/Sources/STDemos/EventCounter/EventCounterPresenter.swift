//
//  EventCounterPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

final class EventCounterPresenter: DemoPresenter<EventCounterViewController> {

}

// MARK: - EventCounterViewControllerDelegate
extension EventCounterPresenter: EventCounterDelegate {
    
    func animate() {
        UILabel.animate(withDuration: 0.3, animations: {
            self.view.eventCounterLabel.textColor = .systemOrange
            self.view.eventCounterLabel.transform = CGAffineTransformMakeScale(1.4, 1.4)
        }) { _ in
            UILabel.animate(withDuration : 1, animations: {
                self.view.eventCounterLabel.textColor = .darkGray
                self.view.eventCounterLabel.transform = CGAffineTransformIdentity
            })
        }
    }
    

    func load() {
        
        demo = .eventCounter
        
        demoFeatures = param.node.characteristics.features(with: Demo.eventCounter.features)
        
        view.configureView()
    }

    
    public func updateCounter(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<EventCounterData>,
           let data = sample.data {
            view.eventCounterLabel.text = String(Int(data.counter.value ?? 0))
            animate()
        }
    }
}
