//
//  BoardHeaderViewModel.swift
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

public class BoardHeaderViewModel: BaseCellViewModel<Board, BoardHeaderCell> {

    let firmwareHandler: (() -> Void)?
    let datasheetsHandler: (() -> Void)?

    public init(param: Board,
                firmwareHandler: (() -> Void)?,
                datasheetsHandler: (() -> Void)?) {
        self.firmwareHandler = firmwareHandler
        self.datasheetsHandler = datasheetsHandler

        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: BoardHeaderCell) {

        TextLayout.title.size(19.0).apply(to: view.titleLabel)
        TextLayout.info.size(16.0).apply(to: view.subtitleLabel)
        TextLayout.infoBold.apply(to: view.statusLabel)
        TextLayout.info.apply(to: view.descriptionLabel)

        guard let param = param else { return }

        view.titleLabel.text = param.name
        view.subtitleLabel.text = param.friendlyName
        if let status = param.status {
            if status == "NRND" {
                view.statusLabel.textColor = ColorLayout.red.light
            } else {
                view.statusLabel.textColor = ColorLayout.green.light
            }
            view.statusLabel.text = status
        }
        //view.descriptionLabel.text = param.description

        view.nodeImageView.contentMode = .scaleAspectFit
        view.nodeImageView.image = param.image

        view.iconImageView.contentMode = .scaleAspectFit
        view.iconImageView.image = param.image

        view.firmwareButton.on(.touchUpInside) { [weak self] _ in
            guard let firmwareHandler = self?.firmwareHandler else { return }
            firmwareHandler()
        }
        
        if param.datasheetsUrl != nil {
            view.datasheetButton.on(.touchUpInside) { [weak self] _ in
                guard let datasheetsHandler = self?.datasheetsHandler else { return }
                datasheetsHandler()
            }
        } else {
            view.datasheetButton.isHidden = true
        }
    }
}

