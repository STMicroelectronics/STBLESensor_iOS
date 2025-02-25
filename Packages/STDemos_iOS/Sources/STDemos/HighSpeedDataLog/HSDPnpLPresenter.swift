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

import UIKit
import STBlueSDK
import STCore
import STUI
import Toast

open class HSDPnpLPresenter: PnpLPresenter {

    public private(set) var logControllerResponse: LogControllerResponse?
    let statusView = HSDWaitingView(text: "Check logging status")

    var waitingView: UIView?

    let waitingContainerViewView = UIView()

    open func configureWaitingView() {

        waitingView = getWaitingView()

        guard let waitingView = waitingView else { return }

        waitingContainerViewView.add(waitingView)
        waitingContainerViewView.isHidden = true
        waitingView.addFitToSuperviewConstraints()
    }

    open override func load() {
        statusView.isVisible = true
        super.load()
        view.view.add(statusView)
        statusView.addFitToSuperviewConstraints()

        view.view.add(waitingContainerViewView)
        waitingContainerViewView.addFitToSafeAreaLayoutGuideConstraints()

        configureWaitingView()

        prepareSettingsMenu()
    }

    open func getWaitingView() -> UIView {
        HSDWaitingView(text: "Device is logging")
    }

    open func resetWaitingView() {

    }

    open func showEndLogMessage() {
        Alert.show(title: "DataLogging completed",
                   message: "You can start another acquisition using the Play button or upload the collected data to your dataset by using the Storage button.",
                   from: self.view)
    }

    open func logStartStop() {

        if !isLogStartStopAvailable() {
            return
        }

        guard let logControllerResponse = logControllerResponse else { return }

        if !(logControllerResponse.sdMounted ?? false) {
            view.navigationController?.viewControllers.last?.view.makeToast("Missing SD Card", position: .center)
            return
        }

        if let status = logControllerResponse.status, status {
            stopLog()
            showEndLogMessage()
        } else {
            prepareLog()
            startLog()
        }
        
        requestStatusUpdate()
    }

    open func isLogStartStopAvailable() -> Bool {
        return true
    }

    open override func requestStatusUpdate() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            BlueManager.shared.sendPnpLCommand(PnpLCommand.logControllerStatus,
                                               maxWriteLength: self.pnpLMaxWriteLength,
                                               to: self.param.node)
        }
    }

    open func prepareLog() {
        setTime()
    }

    func startLog() {
//        {"log_controller*start_log":{"interface":0}}
        StandardHUD.shared.show()
        let command = PnpLCommand.command(element: "log_controller",
                                          param: "start_log",
                                          value: .object(name: "interface",
                                                         value: AnyEncodable(0)))
        
        evaluateSendPnPLCommand(command, withProgress: false)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            BlueManager.shared.sendPnpLCommand(PnpLCommand.simpleJson(element: "get_status",
                                                                      value: .plain(value: "tags_info")),
                                               to: self.param.node)
        }
        
    }

    @discardableResult
    open func setTime() -> Date {

        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HH_mm_ss"
//        formatter.timeZone = TimeZone(secondsFromGMT: 0)
//        formatter.calendar = Calendar(identifier: .iso8601)
//        {"log_controller*set_time":{"datetime":"20230519_09_33_20"}}
        let command = PnpLCommand.command(element: "log_controller",
                                         param: "set_time",
                                         value: .object(name: "datetime",
                                                        value: AnyEncodable(formatter.string(from: date))))
        
        evaluateSendPnPLCommand(command, withProgress: false)
        
        return date
    }

    func stopLog() {
//        {"log_controller*stop_log":{}}
        StandardHUD.shared.show()
        let command = PnpLCommand.emptyCommand(element: "log_controller",
                                               param: "stop_log")
        
        evaluateSendPnPLCommand(command, withProgress: false)
        
    }

    open override func handleUpdate(from feature: PnPLFeature) {
        if let data = feature.sample?.data?.rawData {
            if let logControllerResponse = try? JSONDecoder().decode(LogControllerResponse.self,
                                                                     from: data,
                                                                     keyedBy: "log_controller") {
                self.logControllerResponse = logControllerResponse

                if let status = logControllerResponse.status, !status {
                    statusView.isVisible = false
                    waitingContainerViewView.isHidden = true
                    resetWaitingView()

                    view.stTabBarView?.actionButton.setImage(ImageLayout.Common.playFilled?.template, for: .normal)

                    afterUpdate(from: feature)

                    BlueManager.shared.sendPnpLCommand(PnpLCommand.status,
                                                       maxWriteLength: self.pnpLMaxWriteLength,
                                                       to: self.param.node)
                } else {
                    waitingContainerViewView.isHidden = false
                    waitingContainerViewView.isUserInteractionEnabled = !waitingContainerViewView.isHidden
                    view.stTabBarView?.actionButton.setImage(ImageLayout.Common.stopFilled?.template, for: .normal)
                }
            }
        }

        super.handleUpdate(from: feature)
        
        inactiveSensors.forEach { element in
            director?.elements.removeAll { $0 as? GroupCellViewModel === element as? GroupCellViewModel }
        }

        director?.reloadData()
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
