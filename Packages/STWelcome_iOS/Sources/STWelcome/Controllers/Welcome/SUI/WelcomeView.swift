//
//  WelcomeView.swift
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

public struct WelcomeView: View {
    
    @StateObject private var viewModel: WelcomeViewModel
    
    public init(welcome: Welcome) {
        _viewModel = StateObject(
            wrappedValue: WelcomeViewModel(welcome: welcome)
        )
    }
    
    public var body: some View {
        VStack {
            
            // Pages
            TabView(selection: $viewModel.currentPageIndex) {
                ForEach(Array(viewModel.welcome.pages.enumerated()), id: \.offset) { index, page in
                    WelcomePageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Page control
            HStack(spacing: 8) {
                ForEach(0..<viewModel.totalPages, id: \.self) { index in
                    Circle()
                        .fill(
                            index == viewModel.currentPageIndex
                            ? SUIColorLayout.secondary.color
                            : SUIColorLayout.stGray6.color
                        )
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.top, 8)
            
            HStack {
                Spacer()
                Button(viewModel.currentPage.next ?? "Next") {
                    viewModel.didTapNext()
                }
                .applyButtonLayout(.standard)
                .buttonStyle(.borderedProminent)
                .opacity(viewModel.currentPageIndex == viewModel.totalPages - 1 ? 1.0 : 0.0)
                .disabled(viewModel.currentPageIndex != viewModel.totalPages - 1)
            }
            .padding()
            .frame(height: 80)
        }
        .fullScreenCover(isPresented: $viewModel.showLicense) {
            if let url = viewModel.welcome.licenseUrl {
                LicenseView(url: url)
            }
        }
    }
}
