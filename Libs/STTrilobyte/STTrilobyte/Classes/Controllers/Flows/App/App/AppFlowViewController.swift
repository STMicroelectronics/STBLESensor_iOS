//
//  AppFlowViewController.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 24/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class AppFlowViewController: FooterViewController {
    
    // MARK: View life cycle
    
    var selectdIndexPaths: [IndexPath] = [IndexPath]()
    var tableView = UITableView()
    
    lazy var flows = PersistanceService.shared.getAllCustomFlows().filter { flow -> Bool in
        !flow.hasOutputAsInput
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "app_title".localized()
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = true
        tableView.tableFooterView = UIView()
        
        tableView.registerClassCell(FlowSelectCell.self)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        configureViews()
    }
    
    func configureViews() {
        view.addSubview(tableView)
        tableView.autoAnchorToSuperViewSafeArea()
        
        addFooter(to: tableView)
        
        leftButton?.isHidden = true
        
        rightButton?.setTitle("device_upload".localized().uppercased(), for: .normal)
        rightButton?.setImage(UIImage.named("img_publish"), for: .normal)
    }
    
}

extension AppFlowViewController {
    
    override func rightButtonPressed() {
        
        let selectedFlows = selectdIndexPaths.map { flows[$0.row] }
        
        let error = selectedFlows.isValid()
        
        switch error {
        case .none:
            break
        default:
            ModalService.showWarningMessage(with: error.localizedDescription)
            return
        }
        
        let controller: DeviceListViewController = DeviceListViewController.makeViewControllerFromNib()
        controller.configure(with: selectedFlows)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension AppFlowViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FlowSelectCell.reusableIdentifier(),
                                                 for: indexPath)
        
        if let unwrappedCell = cell as? FlowSelectCell {
            unwrappedCell.configure(with: flows[indexPath.row],
                                    option: selectdIndexPaths.contains(indexPath) ? .selected : .none)
        }
        
        return cell
    }
    
}

extension AppFlowViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let index = selectdIndexPaths.firstIndex(of: indexPath) {
            selectdIndexPaths.remove(at: index)
        } else {
            selectdIndexPaths.append(indexPath)
        }
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
}
