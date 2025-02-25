
//
//  BinaryContentPresent.swift
//
//  Copyright (c) 2024 STMicroelectronics.
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

final class BinaryContentPresent: DemoPresenter<BinaryContentViewController> {
    
    public var director: TableDirector?
    var fullDataReceived = Data()
    var bytesRead = Data()
    
    var firmwareDB: Firmware? = nil
    var binaryMaxWrite: Int = 20
    var pnpLMaxWriteLength: Int = 20
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        //{"get_status":"all"}
        requestStatusUpdate()
    }
}

// MARK: - BinaryContentViewController
extension BinaryContentPresent: BinaryContentDelegate {
    
    func requestStatusUpdate() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.status,
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
    }
    
    func getBinaryContentMaxWriteLength() -> Int {
        return binaryMaxWrite
    }
    
    func sendToBoard(bleChunkWriteSize: Int) {
        self.view.hideSendToBoardSection()
        self.view.hideMessage()
        
        self.view.startSendingIndicator()
        
        if let binaryContentFeature = param.node.characteristics.first(with: BinaryContentFeature.self) {
            
            _ = BlueManager.shared.sendBinaryCommand(bytesRead, to: param.node, feature: binaryContentFeature, writeSize: bleChunkWriteSize, progress: {index, part in
                self.view.updateSendingIndicator(fraction: Float(index)/Float(part-1))
            },
                                                     completion: {
                self.view.showMessage(message: "Binary Content Sent")
                self.view.stopSendingIndicator()
            })
        }
    }
    
    func loadFromFile() {
        self.view.hideSendToBoardSection()
        FilePicker.shared.pickFile(with: [ .bin ]) { url in
            guard let url = url else { return }
            
            guard let data = try? Data(contentsOf: url) else {
                self.view.showMessage(message: "Error Reading File")
                return
            }
            self.view.showMessage(message: "File Read \(data.count) bytes")
            self.bytesRead = data
            self.view.showSendToBoardSection()
            self.view.hideSaveToFileSV()
        }
    }
    
    
    func saveToFile(fileName: String?) {
        self.view.hideSendToBoardSection()
        self.view.hideSaveToFileSV()
        
        let name = fileName ?? "Binary.bin"
        let fullFilename = FileManager.default.customBinaryContentFolder().appendingPathComponent(name )
        
        FileManager.default.createBinaryContentFolderIfNeeded()
        
        if FileManager.default.fileExists(atPath: fullFilename.path) {
            guard (try? FileManager.default.removeItem(atPath: fullFilename.path)) != nil else {
                self.view.showMessage(message: "Error removing \(name)")
                return
            }
        }
        
        if FileManager.default.createFile(atPath: fullFilename.path, contents: fullDataReceived, attributes: nil) {
            self.view.showMessage(message: "Saved \(name)")
        } else {
            self.view.showMessage(message: "Error writing \(name)")
        }
        
        fullDataReceived = Data()
    }
    
    func updatePnPL(with feature: PnPLFeature) {
        guard let sample = feature.sample,
              let response = sample.data?.response,
              let device = response.devices.first else { return }
        
        let codevalues = device.components.codeValues(with: [])
        director?.updateVisibleCells(with: codevalues)
    }
    
    func updateBinaryContent(with feature: BinaryContentFeature) {
        //Show that we had one operation on going
        self.view.startReceivingIndicator()
        
        let data = feature.sample?.data
        
        view.updateReceivingIndicator(bytes: data?.bytesRec.value ?? 0)
        
        
        if let fullDataReceived = data?.rawData.value {
            if !fullDataReceived.isEmpty {
                view.showSaveToFileSV()
                view.hideSendToBoardSection()
                view.hideMessage()
                self.view.stopReceivingIndicator()
                self.fullDataReceived = fullDataReceived
            }
        }
    }
    
    func load() {
        demo = .binaryContent
        
        //Retrieve the Firmware Model from Firmware DB
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog {
            firmwareDB = catalog.v2Firmware(with: param.node)
        }
        
        demoFeatures = param.node.characteristics.features(with: Demo.binaryContent.features)
        
        
        //Search if there is a max write for Binary Content and/or PnPL features
        if firmwareDB != nil {
            for feature in demoFeatures {
                if feature is BinaryContentFeature {
                    if let binaryMaxWrite = firmwareDB?.characteristics?.first(where: { char in char.uuid == feature.type.uuid.uuidString.lowercased()})?.maxWriteLength {
                        if binaryMaxWrite > param.node.mtu {
                            self.binaryMaxWrite = param.node.mtu
                        } else {
                            self.binaryMaxWrite = binaryMaxWrite
                        }
                    }
                } else if feature is PnPLFeature {
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
        
        view.configureView()
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: PnpLComponentViewModel.self, bundle: STDemos.bundle)
            director?.register(viewModel: GroupCellViewModel<[any ViewViewModel]>.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
        }
        
        fullDataReceived = Data()
        
        configureDirector()
        
        view.hideMessage()
        view.hideSendToBoardSection()
        view.hideSaveToFileSV()
        
    }
    
    func configureDirector() {
        director?.onSelect({ indexPath in
            Logger.debug(text: "\(indexPath.section) - \(indexPath.row)")
        })
        
        //Full Dtmi
        //let dtmi: [PnpLContent] = BlueManager.shared.dtmi(for: param.node)?.contents ?? []
        
        //Take only the Control component
        let dtmi: [PnpLContent] = BlueManager.shared.dtmi(for: param.node)?.contents.contents(with: [
            ContentFilter(component: "control",
                          filters: [])], filter: .notSensors) ?? []
        
        guard case let .interface(interface) = dtmi.first else { return }
        
        let components = interface.contents
        
        director?.elements.removeAll()
        director?.elements.append(contentsOf: components.compactMap { component in
            
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
            
            return GroupCellViewModel(childViewModels: viewModels, isOpen: true /* for opening by default the card */, isChildrenIndented: true)
        })
        
        director?.reloadData()
        
        //        requestStatusUpdate()
    }
    
    func handleAction(action: PnpLContentAction,
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
    
    
    func valueChanged(with codeValue: CodeValue<SwitchInput>) {
        guard let value = codeValue.value.value,
              let command = codeValue.jsonCommand(with: value) else { return }
        
        BlueManager.shared.sendPnpLCommand(command,
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
        
        requestStatusUpdate()
    }
    
    func updateValue(with codeValue: CodeValue<TextInput>) {
        guard let boxedValue = codeValue.value.boxedValue,
              let command = codeValue.jsonCommand(with: boxedValue.unwrappedValue) else { return }
        
        BlueManager.shared.sendPnpLCommand(command,
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
        
        requestStatusUpdate()
    }
    
    func sendEmptyAction(with codeValue: CodeValue<ActionInput>) {
        
        guard let command = codeValue.command(with: nil) else { return }
        
        BlueManager.shared.sendPnpLCommand(command,
                                           maxWriteLength: pnpLMaxWriteLength,
                                           to: self.param.node)
        
        requestStatusUpdate()
    }
    
    func sendStringAction(with codeValue: CodeValue<ActionTextInput>, content: PnpLContent) {
        
        guard let value = codeValue.value.value else { return }
        
        if case .command(let pnpLCommandContent) = content,
           let request = pnpLCommandContent.request,
           let command = codeValue.command(with: PnpLCommandValue.object(name: request.name, value: AnyEncodable(value)))  {
            
            BlueManager.shared.sendPnpLCommand(command,
                                               maxWriteLength: pnpLMaxWriteLength,
                                               to: self.param.node)
        } else if let command = codeValue.command(with: PnpLCommandValue.plain(value: value)) {
            BlueManager.shared.sendPnpLCommand(command,
                                               maxWriteLength: pnpLMaxWriteLength,
                                               to: self.param.node)
        }
        
        requestStatusUpdate()
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
                
                BlueManager.shared.sendPnpLCommand(command,
                                                   maxWriteLength: pnpLMaxWriteLength,
                                                   to: self.param.node)
                
                self.requestStatusUpdate()
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
        FilePicker.shared.pickFile(with: [ .json, .bin]) { [weak self] url in
            if let self = self,
               let url = url,
               let content = try? String(contentsOf: url),
               let elementName = elementName,
               let requestName = commandContent.request?.name {
                let ucfValue = content.ucfValue
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
                BlueManager.shared.sendPnpLCommand(command,
                                                   maxWriteLength: pnpLMaxWriteLength,
                                                   to: self.param.node, progress: { index, parts in
                    
                    Logger.debug(text: "\(index)/\(parts)")
                    
                }) { [weak self] in
                    
                    StandardHUD.shared.dismiss()
                    self?.requestStatusUpdate()
                    
                }
            }
        }
    }
}
