
//
//  PnpLPresenter.swift
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

open class PnpLPresenter: DemoBasePresenter<PnpLViewController, [PnpLContent]> {

    var type: PNPLDemoType = .standard
    public var director: TableDirector?
    
    var firmwareDB: Firmware?
    var pnpLMaxWriteLength: Int = 20
    
    var pnpLResponse: Bool? = nil
    var showContentNotMounted: Bool
    
    var inactiveSensors: [(any CellViewModel)] = []

    public init(type: PNPLDemoType = .standard, showContentNotMounted: Bool = true, param: DemoParam<[PnpLContent]>) {
        self.showContentNotMounted = showContentNotMounted
        self.type = type

        super.init(param: param)
    }

    open override func viewWillAppear() {
        super.viewWillAppear()

        requestStatusUpdate()
    }

    open func requestStatusUpdate() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.status,
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
    }

    open func requestStatusUpdate(for codeValue: any KeyValue) {
        guard let element = codeValue.keys.first else { return }

        var components = subComponents(for: element)
        components.append(element)

        for component in components {
            BlueManager.shared.sendPnpLCommand(PnpLCommand.elementStatus(element: component),
                                               maxWriteLength: pnpLMaxWriteLength,
                                               to: self.param.node)
        }
    }

    open func handleSpontaneousMessage(from feature: PnPLFeature) {
        if let sample = feature.sample {
            if let spontaneousMessage = sample.data?.spontaneousMessage {

                switch spontaneousMessage {
                case .error(let errorMessage):

                    self.view.pnplCommandQueue.removeAll()

                    guard let navigator: Navigator = Resolver.shared.resolve() else { return }
                    navigator.dismiss()

                    self.view.makePnPLSpontaneousMessaggeAlertView(PnPLSpontaneousMessageType.error, errorMessage)

                case .warning(let warningMessage):
                    self.view.makePnPLSpontaneousMessaggeAlertView(PnPLSpontaneousMessageType.warning, warningMessage)
                case .info(let infoMessage):
                    self.view.makePnPLSpontaneousMessaggeAlertView(PnPLSpontaneousMessageType.info, infoMessage)
                case .ok(let okMessage):
                    self.view.makePnPLSpontaneousMessaggeAlertView(PnPLSpontaneousMessageType.ok, okMessage)
                }
            }
            if let spontaneousResponseMessage = sample.data?.spontaneousResponseMessage {
                if spontaneousResponseMessage.response.status == false {
                    self.view.makePnPLSpontaneousMessaggeAlertView(PnPLSpontaneousMessageType.error, spontaneousResponseMessage.response.message)
                } else {
                    self.view.presenter.removeFirstQueueAndEventuallySend()
                }
            }
        }
    }

    open func handleUpdate(from feature: PnPLFeature) {
        StandardHUD.shared.dismiss()

        handleSpontaneousMessage(from: feature)

        guard let sample = feature.sample else { return }

        if let response = sample.data?.response,
            let device = response.devices.first  {
            let codevalues = device.components.codeValues(with: [])

            Logger.debug(text: "------> UPDATE CODE VALUES <------")

    //        if pnpLResponse == nil {
    //            //We need to check if there is the flag only the first time == on the first update from PnPL Feature
    //            pnpLResponse = device.components.checkBleResponseFlag()
    //        }

            if pnpLResponse == nil {
                pnpLResponse = device.waitForBleResponses
            }

            director?.updateVisibleCells(with: codevalues)
        } else if let component = sample.data?.singleComponentResponse {
            let codevalues = component.codeValues(with: [])
            director?.updateVisibleCells(with: codevalues)
        }
        
        guard let sample = feature.sample else { return }
        if let response = sample.data?.response,
           let device = response.devices.first  {
            let codevalues = device.components.codeValues(with: [])
            searchForForNotResponsiveSensors(codevalues)
            searchForNotMountedSensors()
            director?.reloadData()
        }

    }

    open func subComponents(for element: String) -> [String] {
        let dtmi: [PnpLContent] = param.param ?? (BlueManager.shared.dtmi(for: param.node)?.contents ?? []).sensors

        let components = element.lowercased().split(separator: "_")
        if components.count >= 2 {
            return []
        }

        var subComponents = [String]()

        for component in dtmi {
            if let name = component.componentDisplayName?.lowercased(),
               let prefix = components.first,
               let suffix = components.last,
               name.hasPrefix(prefix),
               !name.hasSuffix(suffix) {
                subComponents.append(String(name))
            }
        }

        return subComponents
    }

    open func afterUpdate(from feature: PnPLFeature) {
    }

    open func load() {
        demo = .pnpLike

        if type == .highSpeedDataLog {
            view.showTabBar()
        }

        view.title = param.customTitle != nil ? param.customTitle : demo?.title
        
        //Retrieve the Firmware Model from Firmware DB
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog {
            firmwareDB = catalog.v2Firmware(with: param.node)
        }

        demoFeatures = param.node.characteristics.features(with: Demo.pnpLike.features)
        
        //Search if there is a max write for Binary Content and/or PnPL features
        if firmwareDB != nil {
            for feature in demoFeatures {
                if feature is PnPLFeature {
                    if  let pnpLMaxWriteLength = firmwareDB?.characteristics?.first(where: { char in char.uuid == feature.type.uuid.uuidString.lowercased()})?.maxWriteLength {
                        if pnpLMaxWriteLength > param.node.mtu {
                            self.pnpLMaxWriteLength = param.node.mtu
                        } else {
                            self.pnpLMaxWriteLength = pnpLMaxWriteLength
                        }
                    }
                }
            }
        }
        

        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: PnpLComponentViewModel.self, bundle: STDemos.bundle)
            director?.register(viewModel: GroupCellViewModel<[any ViewViewModel]>.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
        }

        view.configureView()

        configureDirector()
    }

    open func configureDirector() {
        director?.onSelect({ indexPath in
            Logger.debug(text: "\(indexPath.section) - \(indexPath.row)")
        })

        let dtmi: [PnpLContent] = param.param ?? (BlueManager.shared.dtmi(for: param.node)?.contents ?? [])

        guard case let .interface(interface) = dtmi.first else { return }

        let components = interface.contents

        let filteredComponents = components.filter { component in
            dtmi.contains { $0.identifier == component.componentSchema }
        }
        
        director?.elements.removeAll()
        director?.elements.append(contentsOf: filteredComponents.compactMap { component in

            var viewModels = [any ViewViewModel]()
            if let headerViewModel = component.viewModels(with: [ interface.displayName?.en ?? "" ],
                                                          name: interface.displayName?.en ?? "", action: { action in

            }).first as? any ViewViewModel {
                viewModels.append(headerViewModel)
            }

            if case let .interface(interfaceContent) = dtmi.first(where: { $0.identifier == component.componentSchema }) {
                var componentViewModels = [any ViewViewModel]()
                for content in interfaceContent.contents {
                    if let models = content.viewModels(with: [ component.componentName ?? "n/a" ], name: component.componentDisplayName ?? "n/a", action: { [weak self] action in

                        guard let self else { return }

                        self.handleAction(action: action,
                                          component: component,
                                          content: content)

                    }) as? [any ViewViewModel] {
                        componentViewModels.append(contentsOf: models)
                    }
                }

                viewModels.append(contentsOf: componentViewModels)

                if let headerViewModel = viewModels.first as? ImageDetailViewModel,
                   let enableViewModel = viewModels.first(where: { currentViewModel in

                       if let currentViewModel = currentViewModel as? SwitchViewModel,
                          let param = currentViewModel.param,
                          param.keys.contains("enable") {
                           return true
                       }
                       return false
                   }) as? SwitchViewModel,
                   let param = enableViewModel.param {

                    let newEnableViewModel = SwitchViewModel(param: CodeValue<SwitchInput>(keys: param.keys,
                                                                                           value: SwitchInput(title: nil,
                                                                                                              value: false,
                                                                                                              isEnabled: true,
                                                                                                              handleValueChanged: { [weak self] value in
                        guard let self else { return }
                        self.valueChanged(with: value)
                    })), layout: PnpLContent.layout)

                    headerViewModel.childViewModel = newEnableViewModel
                }


            }

            return GroupCellViewModel(childViewModels: viewModels, isChildrenIndented: true)
        })

        director?.reloadData()

//        requestStatusUpdate()
    }

    open func handleAction(action: PnpLContentAction,
                           component: PnpLContent,
                           content: PnpLContent) {
        switch action {
        case .showCommandPicker(let codeValue):
            self.showCommandPicker(with: codeValue)
        case .showPicker(let codeValue):
            self.showPicker(with: codeValue)
        case .updateValue(let codeValue):
            self.updateValue(with: codeValue)
        case .valueChanged(let codeValue):
            self.valueChanged(with: codeValue)
        case .emptyAction(let codeValue):
            self.sendEmptyAction(with: codeValue)
        case .textAction(let codeValue):
            self.sendStringAction(with: codeValue, content: content)
        case .loadFile(let codeValue):
            if case let .command(commandContent) = content {
                self.loadFile(with: codeValue,
                              elementName: component.componentName,
                              commandContent: commandContent)
            }
        }
    }
}

// MARK: - PnpLDelegate
extension PnpLPresenter: PnpLDelegate {

    public func update(with feature: PnPLFeature) {
        handleUpdate(from: feature)
    }
}

public extension CodeValue {
    func jsonCommand(with value: Encodable) -> PnpLCommand? {

        if keys.count == 2 {

            let jsonElement = keys[0]
            let jsonParam = keys[1]

            return PnpLCommand.json(element: jsonElement,
                                    param: jsonParam,
                                    value: PnpLCommandValue.plain(value: AnyEncodable(value)))

        } else if keys.count == 3 {

            let jsonElement = keys[0]
            let jsonParam = keys[1]
            let jsonObject = keys[2]

            return PnpLCommand.json(element: jsonElement,
                                    param: jsonParam,
                                    value: PnpLCommandValue.object(name: jsonObject,
                                                                   value: AnyEncodable(value)))
        } else if keys.count == 4 {
            
            let jsonElement = keys[0]
            let jsonParam = keys[1]
            let jsonObject = keys[2]
            let jsonObjectValue = keys[3]
            
            return PnpLCommand.json(
                element: jsonElement,
                param: jsonParam,
                value: PnpLCommandValue.object(
                    name: jsonObject,
                    value: PnpLCommandValue.object(name: jsonObjectValue, value: AnyEncodable(value)).value
                )
            )
        }

        return nil
    }

    func command(with value: PnpLCommandValue?) -> PnpLCommand? {

        if keys.count == 2 {

            let jsonElement = keys[0]
            let jsonParam = keys[1]

            return PnpLCommand.emptyCommand(element: jsonElement, param: jsonParam)

        } else if keys.count == 3 {

            let jsonElement = keys[0]
            let jsonParam = keys[1]
            let jsonObject = keys[2]

            if let value = value {
//                return PnpLCommand.command(element: jsonElement,
//                                           param: jsonParam,
//                                           request: jsonObject,
//                                           value: value)
                return PnpLCommand.commandWithRequest(
                    element: jsonElement,
                    param: jsonParam,
                    request: jsonObject,
                    value: value
                )
            }
        }

        return nil
    }
    
}

public extension PnpLPresenter {
    func valueChanged(with codeValue: CodeValue<SwitchInput>) {
        guard let value = codeValue.value.value,
              let command = codeValue.jsonCommand(with: value) else { return }

        evaluateSendPnPLCommand(command, withProgress: false)

        requestStatusUpdate(for: codeValue)
    }
}

public extension PnpLPresenter {
    
    enum SensorStatusEnum: String {
        case notMounted = "Not Mounted"
        case statusNotReceived = "Status Not Received"
    }
    
    private func setCurrentSensorStatusLabel(_ currentStatus: SensorStatusEnum, _ groupCellViewModel: GroupCellViewModel<[any ViewViewModel]>) {
        groupCellViewModel.childViewModels.forEach { cellViewModel in
            if let imageDetailViewModel = cellViewModel as? ImageDetailViewModel {
                switch currentStatus {
                case .notMounted:
                    imageDetailViewModel.param?.value.mounted = currentStatus.rawValue
                case .statusNotReceived:
                    imageDetailViewModel.param?.value.status = currentStatus.rawValue
                }
                
            }
        }
    }
  
    private func searchForForNotResponsiveSensors(_ codevalues: [any KeyValue]) {
        guard let director = director else { return }
        
        var allCvKeys: [[String]] = []
        for codeValue in codevalues {
            allCvKeys.append(codeValue.keys)
        }
        let codeValuesKeys = allCvKeys.flatMap { $0 }
        
        director.elements.forEach { element in
            if let groupCellViewModel = element as? GroupCellViewModel {
                groupCellViewModel.childViewModels.forEach { cellViewModel in
                    if cellViewModel is SwitchViewModel {
                        if let switchViewModel = cellViewModel as? SwitchViewModel {
                            let currentSwitch = switchViewModel.param
                            if let switchKeys = currentSwitch?.keys {
                                let currentSensors = switchKeys.filter { $0.contains("_") }
                                if let currentSensor = currentSensors.first {
                                    let foundSensor = codeValuesKeys.first(where: { $0.lowercased().elementsEqual(currentSensor.lowercased()) })
                                    if foundSensor == nil {
                                        inactiveSensors.append(groupCellViewModel)
                                        setCurrentSensorStatusLabel(SensorStatusEnum.statusNotReceived, groupCellViewModel)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func searchForNotMountedSensors() {
        guard let director = director else { return }

        director.elements.forEach { element in
            if let groupCellViewModel = element as? GroupCellViewModel {
                groupCellViewModel.childViewModels.forEach { cellViewModel in
                    if cellViewModel is SwitchViewModel {
                        if let switchViewModel = cellViewModel as? SwitchViewModel {
                            let currentSwitch = switchViewModel.param
                            if let currentSwitchTitle = currentSwitch?.value.title {
                                if currentSwitchTitle.lowercased().contains("mounted") {
                                    if let currentSwitchTitleValue = currentSwitch?.value {
                                        if let switchValue = currentSwitchTitleValue.value {
                                            if !switchValue {
                                                inactiveSensors.append(groupCellViewModel)
                                                setCurrentSensorStatusLabel(SensorStatusEnum.notMounted, groupCellViewModel)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private extension PnpLPresenter {

    func updateValue(with codeValue: CodeValue<TextInput>) {
        guard let boxedValue = codeValue.value.boxedValue,
              let command = codeValue.jsonCommand(with: boxedValue.unwrappedValue) else { return }
        
        evaluateSendPnPLCommand(command, withProgress: false)

        requestStatusUpdate(for: codeValue)
    }

    func sendEmptyAction(with codeValue: CodeValue<ActionInput>) {

        guard let command = codeValue.command(with: nil) else { return }

        evaluateSendPnPLCommand(command, withProgress: false)

        requestStatusUpdate()
    }

    func sendStringAction(with codeValue: CodeValue<ActionTextInput>, content: PnpLContent) {

        guard let value = codeValue.value.value else { return }

        if case .command(let pnpLCommandContent) = content,
           let request = pnpLCommandContent.request,
           let command = codeValue.command(with: PnpLCommandValue.object(name: request.name, value: AnyEncodable(value)))  {

            evaluateSendPnPLCommand(command, withProgress: false)

        } else if let command = codeValue.command(with: PnpLCommandValue.plain(value: value)) {

            evaluateSendPnPLCommand(command, withProgress: false)

        }

        requestStatusUpdate(for: codeValue)
    }

    func showCommandPicker(with codeValue: CodeValue<PickerInput>) {
        let optionMenu = UIAlertController(title: nil,
                                           message: Localizer.Pnpl.Text.selectOption.localized,
                                           preferredStyle: .actionSheet)

        guard let options = codeValue.value.options else { return }

        for element in options {
            optionMenu.addAction(UIAlertAction(title: element.description,
                                               style: .default) { [weak self] _ in

                guard let self else { return }

                guard case let .object(object) = element,
                      let object = object as? PnpLEnumerativeValue,
                      let command = codeValue.jsonCommand(with: object.enumValue) else { return }

                evaluateSendPnPLCommand(command, withProgress: false)

                requestStatusUpdate(for: codeValue)
            })
        }

        optionMenu.addAction(UIAlertAction(title: Localizer.Common.cancel.localized,
                                           style: .destructive) { _ in


        })

        self.view.present(optionMenu, animated: true, completion: nil)
    }

    func showPicker(with codeValue: CodeValue<ActionPickerInput>) {
        let optionMenu = UIAlertController(title: nil,
                                           message: Localizer.Pnpl.Text.selectOption.localized,
                                           preferredStyle: .actionSheet)

        guard let options = codeValue.value.options else { return }

        for (index, element) in options.enumerated() {
            optionMenu.addAction(UIAlertAction(title: element.description,
                                               style: .default) { [weak self] _ in

                guard let self else { return }

                self.director?.updateVisibleCells(with: [CodeValue<Int>(keys: codeValue.keys, value: index)])
                //                self.requestStatusUpdate()
            })
        }

        optionMenu.addAction(UIAlertAction(title: Localizer.Common.cancel.localized,
                                           style: .destructive) { _ in


        })

        self.view.present(optionMenu, animated: true, completion: nil)
    }

    func loadFile(with codeValue: CodeValue<ActionInput>,
                  elementName: String?,
                  commandContent: PnpLCommandContent) {
        FilePicker.shared.pickFile(with: [ FileType.json, FileType.bin]) { [weak self] url in
            if let self = self,
               let url = url,
               let content = try? String(contentsOf: url),
               let elementName = elementName,
               let requestName = commandContent.request?.name {
               // let ucfValue = content.ucfValue
                let ucfValue = content.ucfValue2
                let commandContent = commandContent

                let values = AnyEncodable([
                    "data": AnyEncodable(ucfValue),
                    "size": AnyEncodable(ucfValue.count)
                ])

                let value = PnpLCommandValue.object(name: requestName,
                                                    value: values)

                let command = PnpLCommand.command(element: elementName,
                                                  param: commandContent.name,
                                                  value: value)

                StandardHUD.shared.show(with: "Loading file...")

                evaluateSendPnPLCommand(command, withProgress: true)
            }
        }
    }
}

// MARK: - PnPL Command Queue MANAGEMENT
public struct PnPLCommandInQueue {
    let command: PnpLCommand
    let withProgress: Bool
}

public extension PnpLPresenter {
    func evaluateSendPnPLCommand(_ command: PnpLCommand, withProgress: Bool) {
        if pnpLResponse ?? false {
            addCommandToQueueAndCheckSend(PnPLCommandInQueue(command: command, withProgress: withProgress))
        } else {
            sendPnPLCommand(command, withProgress)
        }
    }
    
    func sendPnPLCommand(_ command: PnpLCommand, _ withProgress: Bool) {
        if withProgress {
            BlueManager.shared.sendPnpLCommand(command,
                                               maxWriteLength: pnpLMaxWriteLength,
                                               to: self.param.node, progress: { index, parts in
                Logger.debug(text: "\(index)/\(parts)")
            }) { [weak self] in
                StandardHUD.shared.dismiss()
                self?.requestStatusUpdate()
            }
        } else {
            BlueManager.shared.sendPnpLCommand(command,
                                               maxWriteLength: pnpLMaxWriteLength,
                                               to: self.param.node)
        }
    }
    
    func addCommandToQueueAndCheckSend(_ command: PnPLCommandInQueue, _ withProgress: Bool = false) {
        view.pnplCommandQueue.append(command)
        Logger.debug(category: "PnPL Command Queue", text: "\(view.pnplCommandQueue)")
        
        if view.pnplCommandQueue.count == 1 {
            if let currentCommand = view.pnplCommandQueue.first {
                sendPnPLCommand(currentCommand.command, currentCommand.withProgress)
            }
        }
    }
    
    func removeFirstQueueAndEventuallySend() {
        if !view.pnplCommandQueue.isEmpty {
            view.pnplCommandQueue.removeFirst()
            Logger.debug(category: "PnPL Command Queue", text: "\(view.pnplCommandQueue)")
        }
        
        if view.pnplCommandQueue.count > 0 {
            if let currentCommand = view.pnplCommandQueue.first {
                sendPnPLCommand(currentCommand.command, currentCommand.withProgress)
            }
        }
    }
}

extension String {
    var ucfValue: String {
        var contentFiltered = String(filter { !" \r\n".contains($0) })
        if let acRange = contentFiltered.range(of: "Ac") {
            contentFiltered.removeSubrange(contentFiltered.startIndex..<acRange.upperBound)
        }
        return contentFiltered.replacingOccurrences(of: "Ac", with: "")
    }
    
    var ucfValue2: String {
        let compactString = self.lines
            .filter { isCommentLine(String($0)) }
            .map { $0.compressLine() }
            .joined(separator: "")
        return compactString
    }
    
    private func isCommentLine(_ line: String) -> Bool {
        return !line.starts(with: "--")
    }
}

extension StringProtocol {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
}

extension Substring {
    func compressLine() -> Substring {
        let result: Substring
        if self.contains("WAIT") {
            let substring = self.deletingPrefix("WAIT").replacingOccurrences(of: " ", with: "")
            let value = Int(substring) ?? 000
            result = Substring(String(format: "W%03d",value))
        } else {
            result = self.replacingOccurrences(of: " ", with: "").dropFirst(2)
        }
        
        return result
    }
}

extension Substring {
    func deletingPrefix(_ prefix: Substring) -> Substring {
        guard self.hasPrefix(prefix) else { return self }
        return Substring(String(self.dropFirst(prefix.count)))
    }
}
