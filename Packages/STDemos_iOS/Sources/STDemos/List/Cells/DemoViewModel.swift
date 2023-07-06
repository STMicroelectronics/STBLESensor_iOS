//
//  DemoViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI
import STBlueSDK
import STCore
import UIKit

public class DemoViewModel: BaseCellViewModel<Demo, DemoCell> {

    public var index: Int
    public var isLockedCheckEnabled: Bool

    public init(param: Demo, index: Int, isLockedCheckEnabled: Bool) {
        self.index = index
        self.isLockedCheckEnabled = isLockedCheckEnabled
        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: DemoCell) {

        TextLayout.title.size(20.0).apply(to: view.demoTextLabel)
        TextLayout.info.apply(to: view.demoDetailTextLabel)

        view.demoTextLabel.text = param?.title
        view.demoDetailTextLabel.text = param?.description

//        guard let sessionService: SessionService = Resolver.shared.resolve() else { return }

        view.containerDemoImage.backgroundColor = index % 2 == 0 ? ColorLayout.secondary.light : ColorLayout.yellow.light

//        if sessionService.app?.appMode != .expert {
//            view.demoImageView.backgroundColor = .red
//        }

        view.demoImageView.contentMode = .scaleAspectFit
        view.demoImageView.image = param?.image?.maskWithColor(color: ColorLayout.primary.light)

        view.lockImageView.contentMode = .center
//        view.lockImageView.isHidden = isLockedCheckEnabled ? !(param?.isLocked ?? false) : true
        view.lockImageView.image = ImageLayout.Common.lock?.maskWithColor(color: .lightGray)
        
        if isLockedCheckEnabled {
            if let param = param {
                let isLock = !(param.isLocked || param.isLockedForNotExpert)
                
                view.lockImageView.isHidden = isLock
                
                if !isLock {
                    setOpaqueView(view)
                } else {
                    setNotOpaqueView(view)
                }
            }
        } else {
            view.lockImageView.isHidden = true
        }
    }
    
    private func setOpaqueView(_ view: DemoCell) {
        view.containerDemoImage.alpha = 0.4
        view.demoDetailTextLabel.alpha = 0.4
        view.demoImageView.alpha = 0.4
        view.demoTextLabel.alpha = 0.4
    }
    
    private func setNotOpaqueView(_ view: DemoCell) {
        view.containerDemoImage.alpha = 1.0
        view.demoDetailTextLabel.alpha = 1.0
        view.demoImageView.alpha = 1.0
        view.demoTextLabel.alpha = 1.0
    }
}
