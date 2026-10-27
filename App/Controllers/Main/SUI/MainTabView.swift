//
//  MainTabView.swift
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
import STCatalog

struct MainTabView: View {
    @StateObject private var nodeDiscoveryViewModel = NodeDiscoveryViewModel()

    var body: some View {

        TabView {
            NavigationStack {
                SUINodeListView(viewModel: nodeDiscoveryViewModel)
            }
            .legacyTint(SUIColorLayout.toolbarLegacyWhiteColor.color)
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            NavigationStack {
                BoardListView(conf: BoardListConf(nodeTypesFilter: nil, isDemoListVisible: true))
            }
            .legacyTint(SUIColorLayout.toolbarLegacyWhiteColor.color)
            .tabItem {
                Label("Catalog", systemImage: "book.pages")
            }
        }
        .tint(SUIColorLayout.primary.color)
        .disabled(nodeDiscoveryViewModel.isConnecting)
    }
}

extension View {
    @ViewBuilder
    func legacyTint(_ color: Color) -> some View {
        if #available(iOS 26.0, *) {
            self
        } else {
            self.tint(color)
        }
    }
}
