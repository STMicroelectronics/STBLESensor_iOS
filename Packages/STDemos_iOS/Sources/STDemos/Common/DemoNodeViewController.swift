//
//  DemoNodeViewController.swift
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

class DemoNodeViewController<Presenter, View: UIView>: BaseViewController<Presenter, View>, BlueDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BlueManager.shared.addDelegate(self)

        hideTabBar()

        guard let presenter = presenter as? DemoDelegate else { return }

        presenter.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        BlueManager.shared.removeDelegate(self)

        guard let presenter = presenter as? DemoDelegate else { return }
        
        presenter.viewWillDisappear()
    }

    override open func makeView() -> View {
        View.make(with: STDemos.bundle) as? View ?? View()
    }

    deinit {
        BlueManager.shared.removeDelegate(self)
        Logger.debug(text: "DEINIT: \(String(describing: self))")
        deinitController()
    }

    public func deinitController() {

    }

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {

    }

    func manager(_ manager: BlueManager, didDiscover node: Node) {

    }

    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {

    }

    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        DispatchQueue.main.async { [weak self] in
            if !node.isConnected {
                self?.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
    }

    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {

        guard let sample = sample else { return }

        Logger.debug(text: "\(sample.description)")
    }

    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        Logger.debug(text: "\(response.description)")
    }
}


class DemoNodeNoViewController<Presenter>: BaseNoViewController<Presenter>, BlueDelegate {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BlueManager.shared.addDelegate(self)

        hideTabBar()

        guard let presenter = presenter as? DemoDelegate else { return }

        presenter.viewWillAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        BlueManager.shared.removeDelegate(self)

        guard let presenter = presenter as? DemoDelegate else { return }

        presenter.viewWillDisappear()
    }

    deinit {
        BlueManager.shared.removeDelegate(self)
        Logger.debug(text: "DEINIT: \(String(describing: self))")
        deinitController()
    }

    public func deinitController() {

    }

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {

    }

    func manager(_ manager: BlueManager, didDiscover node: Node) {

    }

    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {

    }

    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        DispatchQueue.main.async { [weak self] in
            if !node.isConnected {
                self?.navigationController?.popToRootViewController(animated: true)
                return
            }
        }
    }

    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {

        guard let sample = sample else { return }

        Logger.debug(text: "\(sample.description)")
    }

    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        Logger.debug(text: "\(response.description)")
    }
}
