//
//  HighSpeedDataLogViewController+TableView.swift
//  W2STApp
//
//  Created by Dimitri Giani on 12/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import BlueSTSDK_Gui
import UIKit

extension HighSpeedDataLogConfigurationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
}

extension HighSpeedDataLogConfigurationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sensors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HSDCharacteristicCell = HSDCharacteristicCell.dequeue(from: tableView, at: indexPath)
        cell.setModel(sensors[indexPath.row], isExpanded: expandendIndexes.contains(indexPath)) { [weak self] in
            self?.toggleCellAtIndex(indexPath)
        }
        cell.switchDidChangeValue = { [weak self] subSensor, isOn in
            guard let self = self else { return }
            self.setSensorEnabled(isOn, sensor: self.sensors[indexPath.row], subSensor: subSensor)
        }
        cell.charTypeOptionWantShowValues = { [weak self] option, subSensor in
            guard let self = self else { return }
            self.showValuesForOption(option, sensor: self.sensors[indexPath.row], subSensor: subSensor)
        }
        cell.didTapLoadConfiguration = { [weak self] subSensor in
            guard let self = self else { return }
            self.chooseMLCDocument(sensor: self.sensors[indexPath.row], subSensor: subSensor)
        }
        
        return cell
    }
    
    private func toggleCellAtIndex(_ indexPath: IndexPath) {
        if expandendIndexes.contains(indexPath) == true {
            expandendIndexes.remove(indexPath)
        } else {
            expandendIndexes.insert(indexPath)
        }
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
    
    private func showValuesForOption(_ option: HSDOptionModel, sensor: HSDSensor, subSensor: HSDSensorTouple) {
        var actions: [UIAlertAction] = []
        
        option.values.forEach { value in
            actions.append(UIAlertAction(title: String(value), style: .default, handler: { [weak self] _ in
                self?.setOptionModel(option, value: value, sensor: sensor, subSensor: subSensor)
                
            }))
        }
        actions.append(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in }))
        
        UIAlertController.presentActionSheet(from: self, title: nil, message: nil, actions: actions)
    }
}
