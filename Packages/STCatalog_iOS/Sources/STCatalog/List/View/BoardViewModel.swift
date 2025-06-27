//
//  BoardViewModel.swift
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

public class BoardViewModel: BaseCellViewModel<Board, BoardCell> {

    public override func configure(view: BoardCell) {

        TextLayout.title.size(19.0).apply(to: view.nodeTextLabel)
        TextLayout.info.size(16.0).apply(to: view.nodeDetailTextLabel)
        TextLayout.infoBold.apply(to: view.nodeStatusLabel)
//        TextLayout.infoBold.apply(to: view.nodeVariantLabel)
//        TextLayout.info.apply(to: view.nodeReleaseDateLabel)
        TextLayout.info.apply(to: view.nodeExtraTextLabel)

        guard let param = param else { return }

        view.nodeTextLabel.text = param.name
        view.nodeDetailTextLabel.text = param.friendlyName
        view.nodeExtraTextLabel.text = param.description
        
        if let status = param.status {
            if status == "NRND" {
                view.nodeStatusLabel.textColor = ColorLayout.red.light
            } else {
                view.nodeStatusLabel.textColor = ColorLayout.green.light
            }
            view.nodeStatusLabel.text = status
            view.nodeStatusLabel.textAlignment = .right
        }
        
//        view.nodeReleaseDateLabel.isHidden = true
//        view.nodeVariantView.isHidden = true
        
//        if let variant = param.variant {
//            view.nodeVariantView.isHidden = false
//            view.nodeVariantLabel.text = variant
//        }
        
//        if let releaseDate = param.releaseDate {
//            view.nodeReleaseDateLabel.isHidden = false
//            view.nodeReleaseDateLabel.text = releaseDate.replacingOccurrences(of: "_", with: "/")
//        }

        view.nodeImageView.contentMode = .scaleAspectFit
        view.nodeImageView.image = param.image

    }
}

extension Board {
    var image: UIImage? {
        guard let imageName = type?.imageName else { return nil }
        return UIImage(named: imageName, in: STUI.bundle, compatibleWith: nil)
    }
}
