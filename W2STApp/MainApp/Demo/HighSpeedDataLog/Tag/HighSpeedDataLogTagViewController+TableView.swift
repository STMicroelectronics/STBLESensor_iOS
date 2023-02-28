//
//  HighSpeedDataLogTagViewController+TableView.swift
//  W2STApp
//
//  Created by Dimitri Giani on 01/02/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

extension HighSpeedDataLogTagViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return modelTags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tag = modelTags[indexPath.row]
        let cell: HSDTagCell = HSDTagCell.dequeue(from: tableView, at: indexPath)
        var tagItem: HSDTag
        
        switch tag {
            case .software(let tag): tagItem = tag
            case .hardware(let tag): tagItem = tag
        }
        
        cell.hsdTag = tagItem
        cell.setIsLogging(state == .logging)
        
        if state == .waiting {
            cell.setEnabled(enabledTags.contains(tagItem))
        } else {
            cell.setEnabled(taggingEnabledTags.contains(tagItem))
        }
        cell.didChangeEnabled = { [weak self] enabled, tag in
            self?.didChangeEnabledTag(tag, enabled: enabled)
        }
        cell.didWantEdit = { [weak self] tag in
            self?.didWantEditTag(tag)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard state == .waiting else { return [] }
        
        return [
            UITableViewRowAction(style: .destructive, title: "generic.delete".localizedFromGUI, handler: { [weak self] _, indexPath in
                self?.removeTagAtIndex(indexPath.row)
            })
        ]
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboard()
    }
}
