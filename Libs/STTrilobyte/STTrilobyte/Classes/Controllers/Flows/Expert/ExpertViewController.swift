//
//  ExpertViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 14/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class ExpertViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var conditionalButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    var flows = [Flow?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "custom_flows".localized()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClassCell(FlowCell.self)
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refresh()
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        let controller: NewFlowViewController = NewFlowViewController.makeViewControllerFromNib()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func conditionalButtonPressed(_ sender: Any) {
        let controller: ConditionalFlowViewController = ConditionalFlowViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        let controller: AppFlowViewController = AppFlowViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}

private extension ExpertViewController {
    
    func upload(_ flow: Flow) {
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
    
    func refresh() {
        flows = PersistanceService.shared.getAllCustomFlows()
        tableView.reloadData()
    }
    
    func configure() {
        titleLabel.text = "custom_flows".localized()
        titleLabel.font = currentTheme.font.bold.withSize(24.0)
        titleLabel.textColor = currentTheme.color.primary
        
        subtitleLabel.text = "upload_and_run".localized()
        subtitleLabel.font = currentTheme.font.regular.withSize(16.0)
        subtitleLabel.textColor = currentTheme.color.text
        
        descriptionLabel.text = "your_flows".localized().uppercased()
        descriptionLabel.font = currentTheme.font.bold.withSize(13.0)
        descriptionLabel.textColor = currentTheme.color.textDark
        
        addButton.setTitle("create_flow".localized().uppercased(), for: .normal)
        addButton.titleLabel?.font = currentTheme.font.bold.withSize(13.0)
        addButton.contentHorizontalAlignment = .center
        
        conditionalButton.setTitle("if".localized().uppercased(), for: .normal)
        conditionalButton.titleLabel?.font = currentTheme.font.bold.withSize(13.0)
        conditionalButton.contentHorizontalAlignment = .center
        
        playButton.setTitle("play".localized().uppercased(), for: .normal)
        playButton.titleLabel?.font = currentTheme.font.bold.withSize(13.0)
        playButton.contentHorizontalAlignment = .center
    }
}

extension ExpertViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        guard let flow = flows[indexPath.row] else { return }
        
        let controller: FlowDetailController = FlowDetailController.makeViewControllerFromNib()
        controller.delegate = self
        controller.configure(with: flow)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ExpertViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return flows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FlowCell.reusableIdentifier(), for: indexPath)
        
        if let cell = cell as? FlowCell, let flow = flows[indexPath.row] {
            cell.delegate = self
            cell.configure(with: flow, option: .editable)
        }
        
        return cell
    }
}

extension ExpertViewController: FlowCellDelegate {
    func cell(_ cell: FlowCell, didPressUploadFlow flow: Flow) {
        upload(flow)
    }
    
    func cell(_ cell: FlowCell, didPressDeleteFlow flow: Flow) {
        ModalService.showConfirm(with: "expert_flow_delete_message".localized()) { [weak self] success in
            if success {
                PersistanceService.shared.delete(flow: flow)
                
                guard let self = self else { return }
                
                self.refresh()
            }
        }
    }
}

extension ExpertViewController: FlowDetailControllerDelegate {
    
    func didSelect(flow: Flow) {
        upload(flow)
    }
    
}
