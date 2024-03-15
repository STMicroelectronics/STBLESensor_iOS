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

final class SensorsTabPresenter: BasePresenter<SensorsTabViewController, Node> {
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
        
        let sensors = PersistanceService.shared.getAllSensors(runningNode: param)
        
        sensors.forEach { flowSensorItem in
            director?.elements.append(FlowSensorItemViewModel(param: flowSensorItem, onFlowSensorClicked: { item in
                self.view.navigationController?.pushViewController(
                    SensorTabDetailPresenter(param: item).start(),
                    animated: true
                )
            }))
        }
        director?.reloadData()
    }

}
