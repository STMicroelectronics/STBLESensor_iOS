//
//  DemoListView.swift
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
import STCore

public struct DemoListView: View {

    @StateObject private var viewModel: DemoListViewModel
    private let onNodeDisconnected: () -> Void

    public init(node: Node, onNodeDisconnected: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: DemoListViewModel(node: node))
        self.onNodeDisconnected = onNodeDisconnected
    }

    public var body: some View {

        List {

            Section {
                NodeHeaderView(node: viewModel.node)
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
            .moveDisabled(true)

            Section {
                ForEach(Array(viewModel.demos.enumerated()), id: \.element.title) { index, demo in
                    DemoRowView(demo: demo, index: index, isLockedCheckEnabled: true)
                        .padding(.vertical, 10)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.select(demo)
                        }
                }
                .onMove(perform: viewModel.move)
            }
        }
        .listStyle(.plain)
        .navigationTitle(Localizer.DemoList.Text.title.localized)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                STToolbarEditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                settingsMenu
            }
        }
        .onAppear {
            viewModel.load()
            viewModel.onNodeDisconnected = onNodeDisconnected
            viewModel.startObservingConnection()
        }
        .onDisappear {
            viewModel.disconnectIfLeavingDemoList()
            viewModel.stopObservingConnection()
        }
        .onChange(of: viewModel.isFirmwareCheckerPresented) { _, isPresented in
            if !isPresented {
                viewModel.firmwareCheckerConfiguration = nil
            }
        }
        .navigationDestination(isPresented: $viewModel.isFirmwareCheckerPresented) {
            if let configuration = viewModel.firmwareCheckerConfiguration {
                SUIFirmwareCheckerView(
                    node: configuration.node,
                    firmwares: configuration.firmwares,
                    completion: configuration.completion,
                    isPresentedModally: false,
                    onCancel: {
                        viewModel.dismissFirmwareChecker()
                    },
                    onInstall: { firmware in
                        viewModel.openFirmwareUpgrade(
                            firmware: firmware,
                            isMandatory: configuration.firmwares.isMandatory,
                            completion: configuration.completion
                        )
                    }
                )
            }
        }
        .navigationDestination(item: $viewModel.selectedDestination) { destination in
            switch destination {
            case .demo(let demo):
                if let swiftUIView = demo.swiftUIView(node: viewModel.node) {
                    swiftUIView
                        .navigationTitle(demo.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .enablingNotifications(for: viewModel.node, demo: demo, automaticNotification: demo.automaticNotification)
                } else {
                    DemoPresenterWrapper(demo: demo, node: viewModel.node)
                        .navigationTitle(demo.title)
                        .navigationBarTitleDisplayMode(.inline)
                        .ignoresSafeArea()
                }
            case .firmwareUpgrade(let configuration):
                SUIFirmwareSelectView(configuration: configuration) {
                    viewModel.selectedDestination = nil
                }
            case .debugConsole:
                SUIDebugConsoleView(node: viewModel.node)
            }
        }
                .tint(SUIColorLayout.primary.color)
        .alert(item: $viewModel.alertInfo) { info in
            if info.showsLoginAction {
                Alert(
                    title: Text(info.title),
                    message: Text(info.message),
                    primaryButton: .default(Text(Localizer.Common.ok.localized)) {
                        login()
                    },
                    secondaryButton: .cancel(Text(Localizer.Common.cancel.localized))
                )
            } else {
                Alert(
                    title: Text(info.title),
                    message: Text(info.message),
                    dismissButton: .default(Text(Localizer.Common.ok.localized))
                )
            }
        }
    }

    var settingsMenu: some View {
        STToolbarMenu {
            Button(Localizer.Firmware.Text.upgrade.localized) {
                viewModel.openFirmwareUpgrade()
            }

            if viewModel.canDebugConsole {
                Button("Debug Console") {
                    viewModel.selectedDestination = .debugConsole
                }
            }
        } label: {
            Image(systemName: "gearshape")
        }
    }

    private func login() {
        guard
            let loginService: LoginService = Resolver.shared.resolve(),
            !loginService.isAuthenticated,
            let controller = rootViewController
        else { return }

        loginService.authenticate(from: controller) { _ in }
    }

    private var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }
}

// MARK: - UIKit bridges (presenter non yet migrated)
struct DemoPresenterWrapper: UIViewControllerRepresentable {
    let demo: Demo
    let node: Node

    func makeUIViewController(context: Context) -> UIViewController {
        demo.presenter(with: node).start()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
