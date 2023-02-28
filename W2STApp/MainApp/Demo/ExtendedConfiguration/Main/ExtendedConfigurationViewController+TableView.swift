//
//  ExtendedConfigurationViewController+TableView.swift
//  W2STApp
//
//  Created by Dimitri Giani on 28/04/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import BlueSTSDK
import UIKit

extension ExtendedConfigurationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        model.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let commandSection = model[section]
        if expandedSections.contains(commandSection) {
            if commandSection == .customCommands {
                return customCommands.count
            } else {
                return commandSection.commands.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        cell.textLabel?.textColor = .black
        cell.detailTextLabel?.text = nil
        cell.detailTextLabel?.numberOfLines = 0
        cell.selectionStyle = .default
        
        let section = model[indexPath.section]
        
        if section == .customCommands {
            let command = customCommands[indexPath.row]
            
            cell.textLabel?.text = command.name
            cell.detailTextLabel?.text = command.note
            cell.isUserInteractionEnabled = true
        } else {
            let command = section.commands[indexPath.row]
            let isAvailable = availableCommands.contains(command)
            
            cell.textLabel?.text = command.title.localizedFromGUI
            cell.textLabel?.textColor = isAvailable ? .black : .gray
            cell.isUserInteractionEnabled = isAvailable ? true : false
            cell.selectionStyle = isAvailable ? .default : .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let commandSection = model[section]
        let view = ExpandableSectionView()
        view.imageView.image = UIImage.namedFromGUI(commandSection.iconName)?.withRenderingMode(.alwaysTemplate)
        view.label.text = commandSection.title.localizedFromGUI
        view.onTap { [weak self] _ in
            self?.toggleSection(commandSection)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = model[indexPath.section]
        
        if section == .customCommands {
            let command = customCommands[indexPath.row]
            sendCustomCommand(command)
        } else {
            let command = section.commands[indexPath.row]
            sendCommand(command)
        }
    }
}
