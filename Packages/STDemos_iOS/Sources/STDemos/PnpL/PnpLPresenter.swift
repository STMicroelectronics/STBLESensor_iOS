
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

    public init(type: PNPLDemoType = .standard, param: DemoParam<[PnpLContent]>) {
        super.init(param: param)
        self.type = type
    }

    open func requestStatusUpdate() {
        BlueManager.shared.sendPnpLCommand(PnpLCommand.status,
                                           to: self.param.node)
    }

    open func handleUpdate(from feature: PnPLFeature) {
        StandardHUD.shared.dismiss()

        guard let sample = feature.sample,
              let response = sample.data?.response,
              let device = response.devices.first else { return }

        let codevalues = device.components.codeValues(with: [])

        director?.updateVisibleCells(with: codevalues)
    }

    open func afterUpdate(from feature: PnPLFeature) {
    }

    @objc
    open func load() {
        demo = .pnpLike

        if type == .highSpeedDataLog {
            view.showTabBar()
        }

        view.title = demo?.title

        demoFeatures = param.node.characteristics.features(with: Demo.pnpLike.features)

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
                    if let models = content.viewModels(with: [ component.componentName ?? "n/a" ], name: component.componentDisplayName ?? "n/a", action: { action in

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
                                                                                                              handleValueChanged: { value in
                        self.valueChanged(with: value)
                    })), layout: PnpLContent.layout)

                    headerViewModel.childViewModel = newEnableViewModel
                }


            }

            return GroupCellViewModel(childViewModels: viewModels)
        })

        director?.reloadData()

        requestStatusUpdate()
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
            self.sendStringAction(with: codeValue)
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

extension CodeValue {
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
//            let jsonObject = keys[2]

            if let value = value {
                return PnpLCommand.command(element: jsonElement,
                                           param: jsonParam,
//                                           request: jsonObject,
                                           value: value)
            }
        }

        return nil
    }
    
}

public extension PnpLPresenter {
    func valueChanged(with codeValue: CodeValue<SwitchInput>) {
        guard let value = codeValue.value.value,
              let command = codeValue.jsonCommand(with: value) else { return }

        BlueManager.shared.sendPnpLCommand(command,
                                           to: self.param.node)

        requestStatusUpdate()
    }
}

private extension PnpLPresenter {

    func updateValue(with codeValue: CodeValue<TextInput>) {
        guard let boxedValue = codeValue.value.boxedValue,
              let command = codeValue.jsonCommand(with: boxedValue.unwrappedValue) else { return }

        BlueManager.shared.sendPnpLCommand(command,
                                           to: self.param.node)

        requestStatusUpdate()
    }

    func sendEmptyAction(with codeValue: CodeValue<ActionInput>) {

        guard let command = codeValue.command(with: nil) else { return }

        BlueManager.shared.sendPnpLCommand(command,
                                           to: self.param.node)

        requestStatusUpdate()
    }

    func sendStringAction(with codeValue: CodeValue<ActionTextInput>) {

        guard let value = codeValue.value.value,
              let command = codeValue.command(with: PnpLCommandValue.plain(value: value)) else { return }

        BlueManager.shared.sendPnpLCommand(command,
                                           to: self.param.node)

        requestStatusUpdate()
    }

    func showCommandPicker(with codeValue: CodeValue<PickerInput>) {
        let optionMenu = UIAlertController(title: nil,
                                           message: Localizer.Pnpl.Text.selectOption.localized,
                                           preferredStyle: .actionSheet)

        guard let options = codeValue.value.options else { return }

        for element in options {
            optionMenu.addAction(UIAlertAction(title: element.description,
                                               style: .default) { _ in

                guard case let .object(object) = element,
                      let object = object as? PnpLEnumerativeValue,
                      let command = codeValue.jsonCommand(with: object.enumValue) else { return }

                BlueManager.shared.sendPnpLCommand(command,
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
                                               style: .default) { _ in

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
                                                   to: self.param.node)

                self.requestStatusUpdate()
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
}
