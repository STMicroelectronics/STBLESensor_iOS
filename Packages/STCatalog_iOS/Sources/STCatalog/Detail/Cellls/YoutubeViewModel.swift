//
//  YoutubeViewModel.swift
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

public class YoutubeViewModel: BaseCellViewModel<Board, YoutubeCell> {

    public override func configure(view: YoutubeCell) {

        guard let param = param else { return }

        if let videoUrl = param.videoId {
            if let vIDRange = videoUrl.range(of: "v=") {
                var videoID = videoUrl[vIDRange.upperBound...].trimmingCharacters(in: .whitespaces)
                if let timeRange = videoID.range(of: "&t=") {
                    videoID = videoID[..<timeRange.lowerBound].trimmingCharacters(in: .whitespaces)
                }
                view.videoView.load(withVideoId: videoID)
            }
        } else {
            view.videoView.isHidden = true
        }
    }
}


