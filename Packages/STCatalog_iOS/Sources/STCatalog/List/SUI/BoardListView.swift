//
//  BoardListView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import STUI
import STBlueSDK
import STDemos

public struct BoardListView: View {

    @StateObject private var viewModel: BoardListViewModel

    public init(conf: BoardListConf) {
        _viewModel = StateObject(wrappedValue: BoardListViewModel(
            nodeTypesFilter: conf.nodeTypesFilter,
            firmwareNamesFilter: conf.firmwareNamesFilter,
            firmwareSupportedVersions: conf.firmwareSupportedVersions,
            isDemoListVisible: conf.isDemoListVisible,
            isGrouped: conf.isGrouped
        ))
    }

    public var body: some View {
        List {
            ForEach(Array(viewModel.boards.enumerated()), id: \.offset) { _, board in
                ZStack {
                    NavigationLink {
                        BoardDetailView(conf: viewModel.boardDetailConf(for: board))
                            .toolbar(.hidden, for: .tabBar)
                    } label: {
                        EmptyView()
                    }
                    .opacity(0)

                    BoardRowView(board: board)
                }
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Localizer.Catalog.Text.title.localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                STToolbarButton {
                    viewModel.isShowingFilters = true
                } label: {
                    SUIImageLayout.Common.filter
                        .renderingMode(.template)
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingFilters) {
            DemoGroupFilterView(
                orderingBy: viewModel.currentOrderFilter,
                demosGroup: viewModel.currentFilter
            ) { result in

                viewModel.applyFilters(result)
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}
