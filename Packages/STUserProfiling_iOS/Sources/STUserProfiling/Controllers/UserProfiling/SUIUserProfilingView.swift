//
//  UserProfilingView.swift
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

public struct SUIUserProfilingView: View {
    @State private var viewModel: SUIUserProfilingViewModel
    let onFinished: () -> Void

    public init(profile: Profile, onFinished: @escaping () -> Void) {
        _viewModel = State(initialValue: SUIUserProfilingViewModel(profile: profile))
        self.onFinished = onFinished
    }

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer(minLength: 50)

                    VStack(spacing: 24) {
                        VStack(spacing: 4) {
                            Text(viewModel.currentStep.title)
                                .applyTextLayout(.title2)
                                .fontWeight(.semibold)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Text(viewModel.currentStep.titleLabel)
                                .applyTextLayout(.text)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        VStack(spacing: 0) {
                            ForEach(viewModel.currentStep.options) { option in
                                ProfilingOptionView(option: option) {
                                    viewModel.select(option: option)
                                }
                            }
                        }
                        
                        if let content = viewModel.selectedContent {
                            Text(content)
                                .applyTextLayout(.text)
                                .multilineTextAlignment(.center)
                                .padding(.top, 8)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 50)
                }
                .frame(minHeight: UIScreen.main.bounds.height - 150)
            }

            HStack {
                Spacer()
                Button(viewModel.currentStep.next) {
                    viewModel.nextStep(onFinished: onFinished)
                }
                .applyButtonLayout(.standard.with(fullWidth: false))
                .frame(width: 120, height: 44)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(viewModel.currentStep.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
