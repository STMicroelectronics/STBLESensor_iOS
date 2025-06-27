//
//  FlowControlTabPresenter.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI
import STCore
import STBlueSDK

open class FlowControlTabPresenter: PnpLPresenter {
    
    func normalizeName(_ name: String) -> String {
        return name.filter { $0 != " " && $0 != "_" }.lowercased()
    }
    
    open override func load() {
        
        if director == nil {
            director = TableDirector(with: view.tableView)
            director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                               type: .fromClass,
                               bundle: STUI.bundle)
            director?.register(viewModel: PnpLComponentViewModel.self, bundle: STDemos.bundle)
            director?.register(viewModel: GroupCellViewModel<[any ViewViewModel]>.self,
                               type: .fromClass,
                               bundle: STDemos.bundle)
        }
  
        super.load()
    }
    
    open override func configureDirector() {
        director?.onSelect({ indexPath in
            Logger.debug(text: "\(indexPath.section) - \(indexPath.row)")
        })

        let dtmi: [PnpLContent] = param.param ?? (BlueManager.shared.dtmi(for: param.node)?.contents ?? [])

        guard case let .interface(interface) = dtmi.first else { return }

        let components = interface.contents

        var filteredComponents = components.filter { component in
            dtmi.contains { $0.identifier == component.componentSchema }
        }
        
        if let loadedApp = searchForLoadedApp(node: param.node) {
            let normalizedAppName = normalizeName(loadedApp)

            if let matchedComponent = filteredComponents.first(where: {
                if case .component(let content) = $0 {
                    return normalizeName(content.name) == normalizedAppName
                }
                return false
            }) {
                filteredComponents = [matchedComponent]
            } else {
                filteredComponents = []
            }
        } else {
            filteredComponents = []
        }
        
        director?.elements.removeAll()
        
        if (filteredComponents.isEmpty) {
            let noContentsLabelViewModel = LabelViewModel(
                param: CodeValue<String>(value: "No Available Control Components"),
                layout: Layout.title2
            )
            director?.elements.append(ContainerCellViewModel(childViewModel: noContentsLabelViewModel, layout: Layout.standard))
        }
            
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
    }
}
