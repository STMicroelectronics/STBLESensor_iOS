//
//  FlowOverviewButtonViewModel.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

class FlowOverviewButtonViewModel: BaseCellViewModel<Void, FlowOverviewButtonCell> {

    var editButtonTouched: (() -> Void)?
    var playButtonTouched: (() -> Void)?
    
    init(param: Void, editButtonTouched: @escaping () -> Void, playButtonTouched: @escaping () -> Void) {
        super.init(param: param)
        self.editButtonTouched = editButtonTouched
        self.playButtonTouched = playButtonTouched
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    override func configure(view: FlowOverviewButtonCell) {
        
        let editImage = ImageLayout.Common.edit?
            .scalePreservingAspectRatio(targetSize: ImageSize.extraSmall)
            .maskWithColor(color: ColorLayout.systemWhite.light)
        
        let uploadImage = ImageLayout.image(with: "flow_upload", in: .module)?
            .scalePreservingAspectRatio(targetSize: ImageSize.extraSmall)
            .maskWithColor(color: ColorLayout.systemWhite.light)
        
        Buttonlayout.standardWithImage(image: editImage).apply(to: view.editButton, text: "EDIT")
        Buttonlayout.standardWithImage(image: uploadImage).apply(to: view.playButton, text: "PLAY")
        
        view.editButton.on(.touchUpInside) { [weak self] _ in
            if let editButtonTouched = self?.editButtonTouched {
                editButtonTouched()
            }
        }
        
        view.playButton.on(.touchUpInside) { [weak self] _ in
            if let playButtonTouched = self?.playButtonTouched {
                playButtonTouched()
            }
        }
    }
}
