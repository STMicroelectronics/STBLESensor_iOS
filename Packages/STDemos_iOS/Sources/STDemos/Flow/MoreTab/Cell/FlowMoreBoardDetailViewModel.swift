//
//  FlowMoreBoardViewModel.swift
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

public class FlowMoreBoardViewModel: BaseCellViewModel<Node, FlowMoreBoardDetailCell> {

    public init(param: Node) {
        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: FlowMoreBoardDetailCell) {

        guard let param = param else { return }

        if param.type == .sensorTileBox {
            view.nodeImage.contentMode = .scaleAspectFill
            view.nodeImage.image = ImageLayout.image(with: "real_board_sensortilebox", in: STUI.bundle)
            view.nodeLabel.text = "STEVAL-MKSBOX1V1"
        } else {
            view.nodeImage.contentMode = .scaleAspectFill
            view.nodeImage.image = ImageLayout.image(with: "real_board_sensortilebox_pro", in: STUI.bundle)
            view.nodeLabel.text = "STEVAL-MKBOXPRO"
        }
    }
}
