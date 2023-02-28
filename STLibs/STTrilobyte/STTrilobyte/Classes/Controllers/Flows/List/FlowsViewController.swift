//
//  FlowsViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class FlowsViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var flows: [Flow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = flows.first?.category
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClassCell(FlowCell.self)
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        addFooterView()
    }
}

private extension FlowsViewController {
    func upload(flow: Flow) {
        
        let error = [flow].isValid()
        
        switch error {
        case .none:
            break
        default:
            ModalService.showWarningMessage(with: error.localizedDescription)
            return
        }
        
        let controller: DeviceListViewController = DeviceListViewController.makeViewControllerFromNib()
        controller.configure(with: [flow])
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func addFooterView() {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 48))
        footerView.backgroundColor = .clear
        
        let expertButton = UIButton(type: .system)
        expertButton.translatesAutoresizingMaskIntoConstraints = false
        expertButton.setTitle("expert_view".localized().uppercased(), for: .normal)
        expertButton.titleLabel?.font = currentTheme.font.bold.withSize(13.0)
        expertButton.contentHorizontalAlignment = .right
        expertButton.addTarget(self, action: #selector(expertButtonPressed), for: .touchUpInside)
        
        footerView.addSubview(expertButton)
        tableView.tableFooterView = footerView
        
        expertButton.heightAnchor.constraint(equalToConstant: 48.0).isActive = true
        expertButton.leftAnchor.constraint(equalTo: footerView.leftAnchor, constant: 24.0).isActive = true
        expertButton.rightAnchor.constraint(equalTo: footerView.rightAnchor, constant: -24.0).isActive = true
    }
    
    @objc
    func expertButtonPressed(_ sender: UIButton) {
        let controller: ExpertViewController = ExpertViewController.makeViewControllerFromNib()
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FlowsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
        let flow = flows[indexPath.row]
        
        let dictionary: [String: Any] = flow.flatJsonDictionary()
        
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
            print(String(data: data, encoding: .utf8) ?? "ERROR PARSING")
        }
        
        let controller: FlowDetailController = FlowDetailController.makeViewControllerFromNib()
        controller.configure(with: flow)
        controller.delegate = self
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FlowsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FlowCell.reusableIdentifier(), for: indexPath)
        
        if let cell = cell as? FlowCell {
            cell.delegate = self
            cell.configure(with: flows[indexPath.row])
        }
        
        return cell
    }
}

extension FlowsViewController: FlowCellDelegate {
    func cell(_ cell: FlowCell, didPressDeleteFlow flow: Flow) {
       
    }
    
    func cell(_ cell: FlowCell, didPressUploadFlow flow: Flow) {
        upload(flow: flow)
    }
}

extension FlowsViewController: FlowDetailControllerDelegate {
    func didSelect(flow: Flow) {
        upload(flow: flow)
    }
}
