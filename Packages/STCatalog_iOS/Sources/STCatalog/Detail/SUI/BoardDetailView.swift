//
//  BoardDetailView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STDemos
import STUI

struct BoardDetailView: View {

    @StateObject private var viewModel: BoardDetailViewModel

    init(conf: BoardConf) {
        _viewModel = StateObject(
            wrappedValue: BoardDetailViewModel(conf: conf)
        )
    }

    var body: some View {

        ScrollView {

            VStack(spacing: 16) {

                BoardHeaderView(
                    board: viewModel.board,
                    firmwareFilter: FirmwareFilter(
                        board: viewModel.board,
                        firmwareNamesFilter: viewModel.conf.firmwareNamesFilter,
                        firmwareSupportedVersions: viewModel.conf.firmwareSupportedVersions
                    ),
                    datasheetHandler: {
                        open(viewModel.board.datasheetsUrl)
                    }
                )

                if viewModel.conf.isDemoListVisible,
                   !viewModel.availableDemos.isEmpty {

                    sectionTitle(
                        Localizer.CatalogDetail.Text.availableDemos.localized
                    )

                    ForEach(
                        Array(viewModel.availableDemos.enumerated()),
                        id: \.offset
                    ) { index, demo in

                        DemoRowView(
                            demo: demo,
                            index: index,
                            isLockedCheckEnabled: false
                        )
                    }
                }

                if viewModel.board.videoId != nil {

                    sectionTitle(
                        Localizer.CatalogDetail.Text.exampleVideo.localized
                    )

                    YoutubeView(board: viewModel.board)
                        .shadow(radius: 8, y: 4)
                }
            }
            .padding(.vertical)
        }
        .safeAreaInset(edge: .bottom) {

            bottomBar
        }
        .navigationTitle(
            Localizer.CatalogDetail.Text.title.localized
        )
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.trackAnalytics()
        }
    }
}

extension BoardDetailView {

    @ViewBuilder
    func sectionTitle(_ title: String) -> some View {

        Text(title)
            .applyTextLayout(.text)
//            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
    }

    var bottomBar: some View {

        let hasBothLinks = viewModel.board.url != nil && viewModel.board.wikiUrl != nil

        return HStack(spacing: 12) {

            if let urlString = viewModel.board.url {
                linkButton(
                    urlString: urlString,
                    icon: SUIImageLayout.Common.shopping,
                    title: hasBothLinks ? "BUY" : "ORDER & BUY",
                    foreground: SUIColorLayout.systemWhite.light,
                    background: SUIColorLayout.primary.color
                )
            }

            if let wikiString = viewModel.board.wikiUrl {
                linkButton(
                    urlString: wikiString,
                    icon: SUIImageLayout.Common.wiki,
                    title: hasBothLinks ? "WIKI" : "WIKI DOCUMENTATION",
                    foreground: SUIColorLayout.primary.color,
                    background: SUIColorLayout.yellow.color
                )
            }

            Spacer()
        }
        .padding()
        .background(.white)
        .shadow(radius: 4)
    }

    @ViewBuilder
    func linkButton(
        urlString: String,
        icon: Image,
        title: String,
        foreground: Color,
        background: Color
    ) -> some View {

        if let url = URL(string: urlString) {
            Link(destination: url) {
                HStack(spacing: 8) {
                    icon
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                    Text(title)
                        .applyTextLayout(.title3.color(foreground))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .foregroundColor(foreground)
                .background(background)
                .cornerRadius(8)
            }
        }
    }

    func open(_ string: String?) {

        guard
            let string,
            let url = URL(string: string)
        else {
            return
        }

        UIApplication.shared.open(url)
    }
}
