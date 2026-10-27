//
//  YoutubePlayerView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STBlueSDK
import YouTubeiOSPlayerHelper

struct YoutubePlayerView: UIViewRepresentable {

    let videoId: String

    func makeUIView(context: Context) -> YTPlayerView {
        let view = YTPlayerView()
        view.load(withVideoId: videoId)
        return view
    }

    func updateUIView(_ uiView: YTPlayerView, context: Context) {}
}

extension Board {

    var youtubeVideoId: String? {

        guard let videoUrl = videoId else {
            return nil
        }

        guard let range = videoUrl.range(of: "v=") else {
            return nil
        }

        var id = String(videoUrl[range.upperBound...])

        if let timeRange = id.range(of: "&t=") {
            id = String(id[..<timeRange.lowerBound])
        }

        return id
    }
}

struct YoutubeView: View {

    let board: Board

    var body: some View {

        if let videoId = board.youtubeVideoId {

            YoutubePlayerView(videoId: videoId)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 20)
        }
    }
}
