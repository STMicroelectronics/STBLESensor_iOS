//
//  FlowTabPresenter.swift
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

final class FlowTabPresenter: DemoBasePresenter<FlowTabViewController, Void> {
    var director: TableDirector?
    var flowCategories: [FlowCategory] = []
}

// MARK: - FlowTabViewControllerDelegate
extension FlowTabPresenter: FlowTabDelegate {

    func load() {
        view.configureView()
        
        director = TableDirector(with: view.tableView)
        
        director?.register(viewModel: FlowAppsCatagoriesViewModel.self,
                           type: .fromClass,
                           bundle: .module)
        director?.register(viewModel: ContainerCellViewModel<any ViewViewModel>.self,
                           type: .fromClass,
                           bundle: STUI.bundle)
        
        flowCategories = getCategories()
        
        searchForCatalogExtraFlow()
        
        setupView()
    }
    
    func setupView(){
        flowCategories.forEach { flowAppCategoryItem in
            director?.elements.append(FlowAppsCatagoriesViewModel(param: flowAppCategoryItem, onFlowAppCategoryClicked: { item in
                self.view.navigationController?.pushViewController(
                    FlowAppCategoryDetailPresenter(
                        param: FlowsAndNodeParam(
                            flows: flowAppCategoryItem.items,
                            node: self.param.node
                        )
                    ).start(),
                    animated: true
                )
            }))
        }
        
        let expertViewButtonViewModel = ButtonViewModel(
            param: CodeValue(value: ButtonInput(title: "EXPERT VIEW", alignment: .right)),
            layout: Layout.standardButton) { _ in
                self.view.navigationController?.pushViewController(
                    FlowExpertPresenter(param: self.param.node).start(),
                    animated: true
                )
            }
        director?.elements.append(ContainerCellViewModel(childViewModel: expertViewButtonViewModel, layout: Layout.standard))
        
        director?.reloadData()
    }
    
    func getCategories() -> [FlowCategory] {
        var categories: [FlowCategory] = []
        let storedFlows = PersistanceService.shared.getAllPreloadedFlows()
        let filteredStoredFlows = filterStoredFlow(storedFlows: storedFlows)
        categories = Dictionary(grouping: filteredStoredFlows, by: { $0.category ?? "" })
            .sorted { $0.key.localizedStandardCompare($1.key) == .orderedAscending }
            .map { FlowCategory(name: $0.key, items: $0.value) }
        categories.forEach { item in
            item.items
        }
        
        return categories
    }
    
    func filterStoredFlow(storedFlows: [Flow]) -> [Flow] {
        var filteredStoredFlows: [Flow] = []
        storedFlows.forEach { flow in
            flow.boardCompatibility?.forEach { board in
                if board.replacingOccurrences(of: "_", with: "").lowercased() == param.node.type.stringValue.replacingOccurrences(of: "_", with: "").lowercased() {
                    filteredStoredFlows.append(flow)
                }
            }
        }
        return filteredStoredFlows
    }

}

public struct FlowCategory {
    let name: String
    let items: [Flow]
}


extension FlowTabPresenter {
    func searchForCatalogExtraFlow() {
        
        guard let extraExamplesFlow = searchForExtraExamplesFlow(node: param.node) else { return }
        guard let sensorsMountedList = searchForMountedDIL24(node: param.node) else { return }
        
        sensorsMountedList.forEach { sensor in
            if let extraFlow = extraExamplesFlow.first(where: { $0.model == sensor }) {
                extraFlow.examplesFlow.forEach { flowUrl in
                    requestCatalogFlow(flowUrl, completion: { flow in
                        if let flow {
                            let flowAppCategoryItem = FlowCategory(name: flow.name, items: [flow])
                            self.flowCategories.append(flowAppCategoryItem)
                            DispatchQueue.main.async {
                                self.director?.elements.removeAll()
                                self.setupView()
                            }
                        }
                    })
                }
            }
        }
    }
    
    func requestCatalogFlow(_ url: String, completion: @escaping (Flow?) -> Void) {
        guard let url = URL(string: url) else { completion(nil); return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { completion(nil); return }
            do {
                let flow = try JSONDecoder().decode(Flow.self, from: data)
                completion(flow)
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
