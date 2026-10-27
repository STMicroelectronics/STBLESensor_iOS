//
//  SUINodeListView.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI
import UIKit
import STBlueSDK
import STCore
import STUserProfiling
import STDemos
import STUI

struct SUINodeListView: View {
    @ObservedObject var viewModel: NodeDiscoveryViewModel
    private let sessionService: SessionService? = Resolver.shared.resolve()
    private let loginService: LoginService? = Resolver.shared.resolve()

    @State private var showFileImporter = false
    @State private var showAppInfoSheet = false
    @State private var showProfile = false
    @State private var showDTDLImporter = false
    @State private var showFilter = false
    @State private var minRSSI: Int = -100

    func showAppInfo() { showAppInfoSheet = true }
    func changeProfile() { showProfile = true }
    func addCustomFirmware() { showFileImporter = true }
    func addCustomDTDL() { showDTDLImporter = true }

    @Environment(\.openURL) private var openURL

    var body: some View {

        ZStack {
            Color(uiColor: .systemGroupedBackground).edgesIgnoringSafeArea(.all)

            if viewModel.discoveredNodes.isEmpty {
                SUINoResultView(action: {
                })
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {

//                     NODE LIST HEADER TEXT
//                     welcomeHeader

                        ForEach(viewModel.filteredNodes, id: \.address) { node in
                            NodeRowView(node: node, viewModel: viewModel)
                                .onTapGesture {
                                    viewModel.connect(to: node)
                                }
                        }
                    }
                    .padding(.vertical)
                }
            }

            if viewModel.isConnecting {
                connectingOverlay
            }

        }
        .refreshable {
            await refreshNodes()
        }
        .navigationTitle("Available Boards")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup {
                STToolbarButton {
                    viewModel.toggleDiscovery()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .rotationEffect(.degrees(viewModel.isDiscovering ? 360 : 0))
                        .animation(
                            viewModel.isDiscovering
                            ? .linear(duration: 1).repeatForever(autoreverses: false)
                            : .default,
                            value: viewModel.isDiscovering
                        )
                        .frame(width: 36, height: 36)
                }

                STToolbarButton {
                    showFilter = true
                } label: {
                    Image(systemName: "line.3.horizontal.decrease")
                        .frame(width: 36, height: 36)
                }
            }

            if #available(iOS 26.0, *) {
                ToolbarSpacer(.fixed)
            }

            ToolbarItemGroup {
                nodeListMenu
            }
        }
        .onAppear { viewModel.startDiscovery() }
        .onDisappear {
            viewModel.stopDiscovery()
            viewModel.cancelConnectionAttempt()
        }
        .alert(
            "Connection failed",
            isPresented: Binding(
                get: { viewModel.connectionErrorMessage != nil },
                set: { if !$0 { viewModel.dismissConnectionError() } }
            )
        ) {
            Button("OK", role: .cancel) {
                viewModel.dismissConnectionError()
            }
        } message: {
            Text(viewModel.connectionErrorMessage ?? "")
        }
        .fileImporter(
            isPresented: $showDTDLImporter,
            allowedContentTypes: [.data]
        ) { result in
            if case let .success(url) = result {
                BlueManager.shared.updateCustomDtmi(with: url) { _, error in
                    if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .sheet(isPresented: $showAppInfoSheet) {
            NavigationView {
                AppInfoView()
            }
        }
        .sheet(isPresented: $showProfile) {
            NavigationStack {
                SUIUserProfilingView(profile: userProfile) {
                    showProfile = false
                }
            }
        }
        .sheet(isPresented: $showFilter) {
            SUINodeFilterView(
                currentValue: minRSSI,
                onValueChanged: { newValue in
                    minRSSI = newValue
                    viewModel.updateRSSIFilter(newValue)
                },
                onDismiss: {
                    showFilter = false
                }
            )
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(20)
        }
        .navigationDestination(item: $viewModel.selectedNode) { node in
            DemoListView(node: node) {
                viewModel.selectedNode = nil
            }
            .toolbar(.hidden, for: .tabBar)
        }
        .tint(SUIColorLayout.primary.color)
        .disabled(viewModel.isConnecting)

    }

//    NODE LIST HEADER
//    var welcomeHeader: some View {
//        Text("Welcome to ST BLE Sensor")
//            .font(.subheadline)
//            .foregroundColor(.secondary)
//            .padding()
//    }
//
//    FLOATING REFRESH BUTTON
//    var refreshButton: some View {
//        Button(action: { viewModel.toggleDiscovery() }) {
//            ZStack {
//                Circle()
//                    .fill(Color.blue)
//                    .frame(width: 60, height: 60)
//                    .shadow(radius: 4)
//
//                Image(systemName: "arrow.clockwise")
//                    .foregroundColor(.white)
//                    .font(.title2)
//                    .rotationEffect(.degrees(viewModel.isDiscovering ? 360 : 0))
//                    .animation(viewModel.isDiscovering ?
//                               Animation.linear(duration: 1).repeatForever(autoreverses: false) :
//                               .default, value: viewModel.isDiscovering)
//            }
//        }
//        .padding(.bottom, 20)
//    }

    private func refreshNodes() async {
        viewModel.stopDiscovery()

        try? await Task.sleep(for: .milliseconds(300))

        viewModel.startDiscovery()
    }

}

extension SUINodeListView {
    func showApplicationSourceCode() {
        if let url = URL(string: "https://github.com/STMicroelectronics/STBLESensor_iOS") {
            openURL(url)
        }
    }

    func showPrivacyPolicy() {
        if let url = URL(
            string: "https://www.st.com/content/st_com/en/common/privacy-portal/corporate-privacy-statement.html"
        ) {
            openURL(url)
        }
    }

    func showAboutST() {
        if let url = URL(string: "https://www.st.com/content/st_com/en/about/st_company_information/who-we-are.html") {
            openURL(url)
        }
    }
}

// MARK: - Connection Overlay
extension SUINodeListView {
    var connectingOverlay: some View {
        ZStack {
            Color.black.opacity(0.25)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .tint(SUIColorLayout.primary.color)

                Text("CONNECTING")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

// MARK: - Menu
extension SUINodeListView {
    var nodeListMenu: some View {
        STToolbarMenu {
            // MARK: - App Info
            Button(appVersionTitle) {
                showAppInfo()
            }

            // MARK: - Custom Firmware
            if canAddCustomFirmware {
                Button(Localizer.NodeList.Text.customFirmware.localized) {
                    addCustomFirmware()
                }
            }

            // MARK: - Custom DTDL
            if canAddCustomDTDL {
                Button(Localizer.NodeList.Text.customDtdl.localized) {
                    addCustomDTDL()
                }
            }

            // MARK: - Profile
            Button(Localizer.NodeList.Action.changeProfile.localized) {
                changeProfile()
            }

            // MARK: - Login / Logout
            Button(loginLogoutTitle) {
                loginLogout()
            }

            Divider()

            // MARK: - Links
            Button("Privacy Policy") {
                showPrivacyPolicy()
            }

            Button("Application Source Code") {
                showApplicationSourceCode()
            }

            Button("About ST") {
                showAboutST()
            }

            // MARK: - Reset FW DB
            if canResetFWDB {
                Button(role: .destructive) {
                    resetFirmwareDB()
                } label: {
                    Text(Localizer.NodeList.Text.resetFwDB.localized)
                }
            }

        } label: {
            Image(systemName: "ellipsis")
        }
    }
}

// MARK: - User Profile
extension SUINodeListView {
    var userProfile: Profile {
        Profile(steps: Profile.defaultProfile.steps) { profile in
            if let sessionService: SessionService = Resolver.shared.resolve() {
                sessionService.update(appMode: profile.selectedAppMode,
                                      userType: profile.selectedUserType)
            }
        }
    }
}

// MARK: - App Version
extension SUINodeListView {
    var appVersionTitle: String {
        var name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "App"
        if UserDefaults.standard.bool(forKey: "isBetaCatalogActivated") {
            name += " (Beta)"
        }
        return "\(name) v\(STCore.appShortVersion)"
    }

    var loginLogoutTitle: String {
        (loginService?.isAuthenticated ?? false) ?
        Localizer.NodeList.Action.logout.localized :
        Localizer.NodeList.Action.login.localized
    }

    var canAddCustomFirmware: Bool {
        (sessionService?.permissions.contains(Permission.addCustomFwDbEntry) ?? false) &&
        !Permission.addCustomFwDbEntry.isAuthenticationRequired
    }

    var canAddCustomDTDL: Bool {
        (sessionService?.permissions.contains(Permission.addCustomDTDLEntry) ?? false) &&
        !Permission.addCustomDTDLEntry.isAuthenticationRequired
    }

    var canResetFWDB: Bool {
        (sessionService?.permissions.contains(Permission.addCustomFwDbEntry) ?? false) &&
        !Permission.addCustomFwDbEntry.isAuthenticationRequired
    }

    var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    }

    func loginLogout() {
        guard let loginService, let controller = rootViewController else { return }

        if loginService.isAuthenticated {
            loginService.resetAuthentication(from: controller) { _ in }
        } else {
            loginService.authenticate(from: controller) { _ in }
        }
    }

    func resetFirmwareDB() {
        BlueManager.shared.clearDB()
    }
}
