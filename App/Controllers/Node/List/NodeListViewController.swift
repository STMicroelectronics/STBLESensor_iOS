//
//  NodeListViewController.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import STCore
import STCatalog

final class NodeListViewController: BaseViewController<NodeListDelegate, NodeListView> {

    static let discoveryTimeout = 10_000

    override func configure() {
        super.configure()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

//        title = Localizer.Home.DeviceList.screenTitle.localized
        title = "Available Boards"

        presenter.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.hidesBackButton = true

        showTabBar()

        BlueManager.shared.addDelegate(self)
        BlueManager.shared.discoveryStop()
        BlueManager.shared.resetDiscovery()
        BlueManager.shared.discoveryStart(NodeListViewController.discoveryTimeout)

        self.presenter.refresh()

        handleAppStateForeground {
            BlueManager.shared.resetDiscovery()
            BlueManager.shared.discoveryStart(NodeListViewController.discoveryTimeout)
        } background: {
            BlueManager.shared.discoveryStop()
            BlueManager.shared.resetDiscovery()
        }

        stTabBarView?.removeAllTabs()

        stTabBarView?.add(TabBarItem(with: Localizer.Home.Text.catalog.localized,
                                     image: ImageLayout.Common.catalog?.template,
                                     callback: { [weak self]_ in

//            guard let sessionService: SessionService = Resolver.shared.resolve(),
//            sessionService.permissions.contains(.exploreCatalog),
//            !(Permission.exploreCatalog.isAuthenticationRequired) else {
//                guard let self = self else { return }
//                UIAlertController.show(
//                    error: STError.generic(
//                        text: "Enabled: \(Permission.exploreCatalog.appModesEnabled)
//                        - \(Permission.exploreCatalog.userTypesEnabled)"),
//                                       from: self)
//                return
//            }

            self?.navigationController?.pushViewController(
                BoardListPresenter(param: BoardListConf(
                    nodeTypesFilter: nil, 
                    firmwareNamesFilter: nil,
                    isDemoListVisible: true)
                ).start(),
                animated: true)
        }), side: .first)

        stTabBarView?.add(TabBarItem(with: Localizer.Home.Text.filter.localized,
                                     image: ImageLayout.Common.filter?.template,
                                     callback: { [weak self] _ in
            self?.presenter.showFilters()
        }), side: .second)

        stTabBarView?.actionButton.setImage(ImageLayout.Common.refresh?.template, for: .normal)
        stTabBarView?.setMainAction { _ in
            if BlueManager.shared.isDiscovering {
                BlueManager.shared.discoveryStop()
            } else {
                BlueManager.shared.discoveryStart(NodeListViewController.discoveryTimeout)
            }
        }

    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        cancelAppStateHandlers()

        self.stTabBarView?.actionButton.stopRotation()

        BlueManager.shared.removeDelegate(self)
        BlueManager.shared.discoveryStop()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func configureView() {
        super.configureView()
    }

    deinit {
        BlueManager.shared.removeDelegate(self)
        BlueManager.shared.resetDiscovery()
        Logger.debug(text: "DEINIT: \(String(describing: self))")
    }
    
    private func sendNodeAnalytics(node: Node) {
        if let analytics: AnalyticsService = Resolver.shared.resolve() {
            if let nodeName = node.name {
                analytics.etnaNodeBaseAnalytics(nodeName: nodeName, nodeType: node.type.stringValue)
            }
            if let catalogService: CatalogService = Resolver.shared.resolve(),
               let fullFirmwareInfos = catalogService.catalog?.v2Firmware(with: node)?.compoundName {
                analytics.etnaNodeFullFwNameAnalytics(fullFwName: fullFirmwareInfos)
            }
        }
    }

}

extension NodeListViewController: BlueDelegate {

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {
        DispatchQueue.main.async { [weak self] in
            if isDiscovering {
                self?.stTabBarView?.actionButton.rotate()
            } else {
                self?.stTabBarView?.actionButton.stopRotation()
            }
        }
    }

    func manager(_ manager: BlueManager, didDiscover node: Node) {
        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }
            self.presenter.updateNodes()
        }
    }

    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {
        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }
            self.presenter.refresh()
        }
    }

    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        if node.state == .connected {
            DispatchQueue.main.async { [weak self] in
                StandardHUD.shared.dismiss()
                self?.sendNodeAnalytics(node: node)
                guard let self = self else { return }
                self.stTabBarView?.actionButton.stopRotation()
                self.presenter.show(node)
            }
        }
//        else {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
//                guard let self = self else { return }
//
//                BlueManager.shared.discoveryStop()
//                BlueManager.shared.resetDiscovery()
//                BlueManager.shared.discoveryStart(NodeListViewController.discoveryTimeout)
//
//                self.presenter.refresh()
//            }
//        }
    }

    func manager(_ manager: BlueManager, didUpdateValueFor: Node, feature: Feature, sample: AnyFeatureSample?) {

    }

    func manager(_ manager: BlueManager,
                 didReceiveCommandResponseFor node: Node,
                 feature: Feature,
                 response: FeatureCommandResponse) {

    }
}
