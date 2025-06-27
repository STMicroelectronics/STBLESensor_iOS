//
//  SensorsTabPresenter.swift
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

final class SensorsTabPresenter: DemoBasePresenter<SensorsTabViewController, Void> {
    var director: TableDirector?
}

// MARK: - SensorsTabViewControllerDelegate
extension SensorsTabPresenter: SensorsTabDelegate {

    func load() {
        view.configureView()
        
        director = TableDirector(with: view.tableView)
        
        director?.register(viewModel: FlowSensorItemViewModel.self,
                           type: .fromClass,
                           bundle: .module)
        director?.register(viewModel: ContainerCellViewModel
                           <any ViewViewModel>.self,
                           type: .fromClass,
                           bundle: STUI.bundle)
        
        let sensors = PersistanceService.shared.getAllSensors(runningNode: param.node)
        
        let sensorsTitleViewModel = LabelViewModel(param: CodeValue<String>(value: "Sensors"),
                                                 layout: Layout.title)
        director?.elements.append(ContainerCellViewModel(childViewModel: sensorsTitleViewModel, layout: Layout.title2))
        
        let sensorsDescrLabelViewModel = LabelViewModel(param: CodeValue<String>(value: "Available Sensors"),
                                                     layout: Layout.info)
        director?.elements.append(ContainerCellViewModel(childViewModel: sensorsDescrLabelViewModel, layout: Layout.info))
        
        sensors.forEach { flowSensorItem in
            director?.elements.append(FlowSensorItemViewModel(param: flowSensorItem, isMounted: true, onFlowSensorClicked: { item in
                self.view.navigationController?.pushViewController(
                    SensorTabDetailPresenter(param: item).start(),
                    animated: true
                )
            }))
        }
        
        let expansionTitleViewModel = LabelViewModel(param: CodeValue<String>(value: "Expansion Sensors Boards"),
                                                 layout: Layout.title)
        director?.elements.append(ContainerCellViewModel(childViewModel: expansionTitleViewModel, layout: Layout.title2))
        
        let expansionDescrLabelViewModel = LabelViewModel(param: CodeValue<String>(value: "Supported DIL24 STEVAL Sensors"),
                                                     layout: Layout.info)
        director?.elements.append(ContainerCellViewModel(childViewModel: expansionDescrLabelViewModel, layout: Layout.info))
        
        var expansionSensors: [FlowSensorItemViewModel] = []
        
        if let catalogService: CatalogService = Resolver.shared.resolve() {
            catalogService.catalog?.sensorAdapters?.forEach { adapter in
                let flowSensorItem = fromSensorAdapterToSensor(adapter)
                expansionSensors.append(FlowSensorItemViewModel(param: flowSensorItem, isMounted: isDIL24Mounted(searchForMountedDIL24(node: param.node), flowSensorItem), onFlowSensorClicked: { item in
                    self.view.navigationController?.pushViewController(
                        SensorTabDetailPresenter(param: item).start(),
                        animated: true
                    )
                }))
            }
        }
        
        let expansionSensorsSorted = expansionSensors.sorted { $0.isMounted && !$1.isMounted }
        expansionSensorsSorted.forEach { expansionSensor in
            director?.elements.append(expansionSensor)
        }
        
        director?.reloadData()
    }

}
