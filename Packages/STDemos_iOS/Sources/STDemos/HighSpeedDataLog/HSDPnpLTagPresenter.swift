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

open class HSDPnpLTagPresenter: PnpLPresenter {

    var logControllerResponse: LogControllerResponse?
    let waitingView = HSDWaitingView(text: "Check logging status")

    public override func load() {
        waitingView.isVisible = false
        super.load()
        view.view.addSubview(waitingView)
        waitingView.addFitToSuperviewConstraints()
    }

    public override func requestStatusUpdate() {
//        super.requestStatusUpdate()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            BlueManager.shared.sendPnpLCommand(PnpLCommand.logControllerStatus,
                                               maxWriteLength: self.pnpLMaxWriteLength,
                                               to: self.param.node)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            BlueManager.shared.sendPnpLCommand(PnpLCommand.simpleJson(element: "get_status",
                                                                      value: .plain(value: "tags_info")),
                                               to: self.param.node)
        }
    }

    public override func handleUpdate(from feature: PnPLFeature) {
        if let data = feature.sample?.data?.rawData {
            if let logControllerResponse = try? JSONDecoder().decode(LogControllerResponse.self,
                                                                     from: data,
                                                                     keyedBy: "log_controller") {
                self.logControllerResponse = logControllerResponse

                if let status = logControllerResponse.status {
                    waitingView.isVisible = false
                    let dtmi = BlueManager.shared.dtmi(for: param.node)
                    if status {
                        param.param = dtmi?.contents.settingsLogging
                        view.stTabBarView?.actionButton.setImage(ImageLayout.Common.stopFilled?.template, for: .normal)
                    } else {
                        view.stTabBarView?.actionButton.setImage(ImageLayout.Common.playFilled?.template, for: .normal)
                        param.param = dtmi?.contents.settingsNotLogging
                    }
                    configureDirector()
                } else {
//                    let dtmi = BlueManager.shared.dtmi(for: param.node)
//                    param.param = dtmi?.contents.settingsNotLogging
//                    configureDirector()
                    waitingView.isVisible = true
                    waitingView.isUserInteractionEnabled = !waitingView.isHidden
                    view.stTabBarView?.actionButton.setImage(ImageLayout.Common.stopFilled?.template, for: .normal)
                }

            } else if let logTagsInfoJsonValue = try? JSONDecoder().decode(JSONValue.self,
                                                                           from: data,
                                                                           keyedBy: "tags_info") {
                
                var logTagsInfoResponse = LogTagsInfoResponse(jsonValue: logTagsInfoJsonValue)
                
                if let status = self.logControllerResponse?.status {
                    if status {
                        let dtmi = BlueManager.shared.dtmi(for: param.node)
                        param.param = dtmi?.contents.filteredTags(activeTags: retrieveActiveTags(logTagsInfoResponse))
                        configureDirector()
                    }
                }
                
                logTagsInfoResponse.tags.removeAll()
                logTagsInfoResponse.tags.append(contentsOf: logTagsInfoResponse.tags)
                
                director?.updateVisibleCells(with: logTagsInfoResponse.codeValues)
            }
        }
        
        super.handleUpdate(from: feature)
    }
    
    open func logStartStop() {
        guard let logControllerResponse = logControllerResponse else { return }

        if !(logControllerResponse.sdMounted ?? false) {
            view.navigationController?.viewControllers.last?.view.makeToast("Missing SD Card", position: .center)
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
    
    func stopLog() {
        StandardHUD.shared.show()
        let command = PnpLCommand.emptyCommand(element: "log_controller",
                                               param: "stop_log")
        
        evaluateSendPnPLCommand(command, withProgress: false)
        
    }
    
    open func prepareLog() {
        setTime()
    }

    func startLog() {
        StandardHUD.shared.show()
        let command = PnpLCommand.command(element: "log_controller",
                                          param: "start_log",
                                          value: .object(name: "interface",
                                                         value: AnyEncodable(0)))
        
        evaluateSendPnPLCommand(command, withProgress: false)
        
    }

    @discardableResult
    open func setTime() -> Date {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd_HH_mm_ss"
        let command = PnpLCommand.command(element: "log_controller",
                                         param: "set_time",
                                         value: .object(name: "datetime",
                                                        value: AnyEncodable(formatter.string(from: date))))
        
        evaluateSendPnPLCommand(command, withProgress: false)
        
        return date
    }
    
    private func retrieveActiveTags(_ logTagsInfoResponse: LogTagsInfoResponse) -> [String] {
        var tags: [TagsInfo] = logTagsInfoResponse.tags
        tags = tags.filter { $0.enabled == true }
        var activeTags: [String] = []
        tags.forEach { tag in
            if let tagName = tag.identifier {
                activeTags.append(tagName)
            }
        }
        return activeTags
    }
}

public struct TagsInfo {
    public let label: String
    public var enabled: Bool
    public var temporaryDisabled: Bool
    public let status: Bool
    public var index: Int?
    public var identifier: String?

    public init(dictionary: [String: JSONValue], key: String) {
        identifier = key

        if case .string(let value) = dictionary["label"] {
            label = value
        } else {
            label = ""
        }

        if case .bool(let value) = dictionary["enabled"] {
            enabled = value
        } else {
            enabled = false
        }

        if case .bool(let value) = dictionary["status"] {
            status = value
        } else {
            status = false
        }

        if case .bool(let value) = dictionary["temporary_disabled"] {
            temporaryDisabled = value
        } else {
            temporaryDisabled = false
        }
    }

    public init(label: String, enabled: Bool, temporaryDisabled: Bool = false, status: Bool, index: Int? = nil, identifier: String? = nil) {
        self.label = label
        self.enabled = enabled
        self.temporaryDisabled = temporaryDisabled
        self.status = status
        self.index = index
        self.identifier = identifier
    }
}

public struct LogTagsInfoResponse {

    private let ignoredKeys = ["hw_tag", "max_tags_num", "c_type"]

    public var tags: [TagsInfo] = []

    public init(jsonValue: JSONValue) {
        if case .object(let dictionary) = jsonValue {
            dictionary.keys.forEach { key in
                if !ignoredKeys.contains(key) {
                    if case .object(let dictionary) = dictionary[key] {
                        let tagsInfo = TagsInfo(dictionary: dictionary, key: key)
                        tags.append(tagsInfo)
                    }
                }
            }
        }
    }

    public var codeValues: [any KeyValue] {

        var codevalues = [any KeyValue]()

        codevalues.append(contentsOf: tags.compactMap { tag in

            guard let identifier = tag.identifier else { return nil }

            return CodeValue(keys: ["tags_info", identifier, "label"], value: tag.label)
        })

        codevalues.append(contentsOf: tags.compactMap { tag in

            guard let identifier = tag.identifier else { return nil }

            return CodeValue(keys: ["tags_info", identifier, "status"], value: tag.status)
        })

        codevalues.append(contentsOf: tags.compactMap { tag in

            guard let identifier = tag.identifier else { return nil }

            return CodeValue(keys: ["tags_info", identifier, "enabled"], value: tag.enabled)
        })
        
        codevalues.append(contentsOf: tags.compactMap { tag in

            guard let identifier = tag.identifier else { return nil }

            return CodeValue(keys: ["tags_info", identifier, "temporary_disabled"], value: tag.temporaryDisabled)
        })

        return codevalues

    }
}
