//
//  HSDPnpLTagPresenter.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK
import STCore
import STUI

public final class HSDPnpLTagPresenter: PnpLPresenter {

    var logControllerResponse: LogControllerResponse?
    let waitingView = HSDWaitingView(text: "Check logging status")

    public override func load() {
        waitingView.isVisible = false
        super.load()
        view.view.addSubview(waitingView)
        waitingView.addFitToSuperviewConstraints()
    }

    public override func requestStatusUpdate() {
        super.requestStatusUpdate()
    }

    public override func handleUpdate(from feature: PnPLFeature) {
        if feature.sample?.data?.response != nil {
            super.handleUpdate(from: feature)
        } else if let data = feature.sample?.data?.rawData {
            if let logControllerResponse = try? JSONDecoder().decode(LogControllerResponse.self,
                                                                     from: data,
                                                                     keyedBy: "log_controller") {
                self.logControllerResponse = logControllerResponse

                if let status = logControllerResponse.status {
                    waitingView.isVisible = false
                    let dtmi = BlueManager.shared.dtmi(for: param.node)
                    if status {
                        param.param = dtmi?.contents.settingsLogging
                        view.stTabBarView?.actionButton.setImage(ImageLayout.Common.pause?.template, for: .normal)
                    } else {
                        view.stTabBarView?.actionButton.setImage(ImageLayout.Common.play?.template, for: .normal)
                        param.param = dtmi?.contents.settingsNotLogging
                    }
                    configureDirector()
                } else {
                    waitingView.isVisible = true
                    waitingView.isUserInteractionEnabled = !waitingView.isHidden
                    view.stTabBarView?.actionButton.setImage(ImageLayout.Common.pause?.template, for: .normal)
                }

            }
        }
    }
}
