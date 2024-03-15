//
//  HSDPnpLPresenter.swift
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
import Toast

open class HSDPnpLPresenter: PnpLPresenter {

    public private(set) var logControllerResponse: LogControllerResponse?
    let waitingView = HSDWaitingView(text: "Check logging status")

    open override func load() {
        waitingView.isVisible = true
        super.load()
        view.view.addSubview(waitingView)
        waitingView.addFitToSuperviewConstraints()

        prepareSettingsMenu()
    }

    open func logStartStop() {
        guard let logControllerResponse = logControllerResponse else { return }

        if !(logControllerResponse.sdMounted ?? false) {
            view.view.makeToast("Missing SD Card", position: .center)
            return
        }

        if let status = logControllerResponse.status, status {
            stopLog()
        } else {
            prepareLog()
            startLog()
        }
        
        requestStatusUpdate()
    }

    open override func requestStatusUpdate() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            BlueManager.shared.sendPnpLCommand(PnpLCommand.simpleJson(element: "get_status",
                                                                      value: .plain(value: "log_controller")),
                                               to: self.param.node)
        }
    }

    open func prepareLog() {
        setTime()
    }

    func startLog() {
//        {"log_controller*start_log":{"interface":0}}
        StandardHUD.shared.show()
        BlueManager.shared.sendPnpLCommand(PnpLCommand.command(element: "log_controller",
                                                               param: "start_log",
                                                               value: .object(name: "interface",
                                                                              value: AnyEncodable(0))),
                                           to: self.param.node)
    }

    @discardableResult
    open func setTime() -> Date {

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HH_mm_ss"
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.calendar = Calendar(identifier: .iso8601)
//        {"log_controller*set_time":{"datetime":"20230519_09_33_20"}}
        BlueManager.shared.sendPnpLCommand(PnpLCommand.command(element: "log_controller",
                                                               param: "set_time",
                                                               value: .object(name: "datetime",
                                                                              value: AnyEncodable(formatter.string(from: date)))),
                                           to: self.param.node)

        return date
    }

    func stopLog() {
//        {"log_controller*stop_log":{}}
        StandardHUD.shared.show()
        BlueManager.shared.sendPnpLCommand(PnpLCommand.emptyCommand(element: "log_controller",
                                                                    param: "stop_log"),
                                           to: self.param.node)
    }

    open override func handleUpdate(from feature: PnPLFeature) {
        if let data = feature.sample?.data?.rawData {
            if let logControllerResponse = try? JSONDecoder().decode(LogControllerResponse.self,
                                                                     from: data,
                                                                     keyedBy: "log_controller") {
                self.logControllerResponse = logControllerResponse

                if let status = logControllerResponse.status, !status {
                    waitingView.isVisible = false
                    waitingView.update(text: "Check logging status")
                    view.stTabBarView?.actionButton.setImage(ImageLayout.Common.play?.template, for: .normal)

                    afterUpdate(from: feature)

                    BlueManager.shared.sendPnpLCommand(PnpLCommand.status,
                                                       to: self.param.node)
                } else {
                    waitingView.isVisible = true
                    waitingView.update(text: "Device is logging")
                    waitingView.isUserInteractionEnabled = !waitingView.isHidden
                    view.stTabBarView?.actionButton.setImage(ImageLayout.Common.pause?.template, for: .normal)
                }

            }
        }

        super.handleUpdate(from: feature)
    }
}

public struct LogControllerResponse {
    public let status: Bool?
    public let sdMounted: Bool?
    public let controllerType: Int?
    public let cType: Int?

    public init(status: Bool?, sdMounted: Bool?, controllerType: Int?, cType: Int?) {
        self.status = status
        self.sdMounted = sdMounted
        self.controllerType = controllerType
        self.cType = cType
    }
}

extension LogControllerResponse: Decodable {
    enum CodingKeys: String, CodingKey {
        case status = "log_status"
        case sdMounted = "sd_mounted"
        case controllerType = "controller_type"
        case cType = "c_type"
    }
}
