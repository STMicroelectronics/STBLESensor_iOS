//
//  PnpLViewController.swift
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

final public class PnpLViewController: DemoNodeTableViewController<PnpLDelegate, PnpLView> {

    public var pnplCommandQueue: [PnPLCommandInQueue] = []
    
    public override func configure() {
        super.configure()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        title = "PnpL_title"

        self.removeDelegateWhenDisappear = false
        presenter.load()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    public override func viewWillDisappear(_ animated: Bool) {
        //self.presenter.disableNotificationOnDisappear = false
        super.viewWillDisappear(animated)
    }

    public override func configureView() {
        super.configureView()
    }

    public override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
//            guard let self = self else { return }
//            if type(of: self.feature) != type(of: feature) ||
//                feature.type.mask != self.feature.type.mask {
//                return
//            }
//
        guard let feature = feature as? PnPLFeature else { return }

        self.presenter.update(with: feature)

    }
}

public extension UIViewController {
    func makePnPLSpontaneousMessaggeAlertView(_ view: UIViewController, _ type: PnPLSpontaneousMessageType, _ description: String) {
        DispatchQueue.main.async {

            Logger.debug(text: "ERRRRRROR: \(description)")

            let extra = "It seems the issue may be related to your SD card. Please ensure it is properly inserted and compatible with the FP-SNS-DATALOG2. Please remember to click the RESTART button on your board to restore it. For a list of recommended and compatible SD cards, click on \'Read More\' button."
            let url = "https://github.com/STMicroelectronics/fp-sns-datalog2?tab=readme-ov-file#known-limitations"
            let actionTitle = "Read More..."

//            guard let navigator: Navigator = Resolver.shared.resolve() else { return }

            if description.lowercased().contains("sd") || description.lowercased().contains("log") {
                let presenter = PnPLSpontaneousMessageAlertPresenter(param: PnPLSpontaneousMessageTypeAndDescription(type: type,
                                                                                                                     description: description,
                                                                                                                     extra: extra,
                                                                                                                     actionTitle: actionTitle,
                                                                                                                     url: url))

                view.present(presenter.start(), animated: true)
            } else {
                let presenter = PnPLSpontaneousMessageAlertPresenter(param: PnPLSpontaneousMessageTypeAndDescription(type: type,
                                                                                                                     description: description))
                view.present(presenter.start(), animated: true)
            }
        }
    }
}
