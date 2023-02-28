//
//  DeviceListViewController.swift
//  trilobyte-lib-ios
//
//  Created by Stefano Zanetti on 17/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit
import BlueSTSDK

class DeviceListViewController: BaseViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var nodes: [BlueSTSDKNode] = [BlueSTSDKNode]()
    var toUpload: Uploadable?
    
    // MARK: View life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "device_list_title".localized()
        
        titleLabel.text = "device_list_available_boards_title".localized()
        titleLabel.font = currentTheme.font.bold.withSize(24.0)
        titleLabel.textColor = currentTheme.color.primary
        
        subtitleLabel.text = "device_list_available_boards_subtitle".localized()
        subtitleLabel.font = currentTheme.font.regular.withSize(16.0)
        subtitleLabel.textColor = currentTheme.color.text
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClassCell(DeviceCell.self)
        tableView.contentInset = UIEdgeInsets(top: 20.0, left: 0.0, bottom: 0.0, right: 0.0)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        nodes.removeAll()
        
        CommunicationService.shared.startDiscoveringNodes { [weak self] nodes, success in
            
            guard let self = self else { return }
            
            if success {
                self.nodes = nodes.filter{ $0.type == .sensor_Tile_Box || $0.type == .SENSOR_TILE_BOX_PRO }
                self.tableView.reloadData()
            } else {
                self.activityIndicator.stopAnimating()
                if self.nodes.isEmpty {
                    ModalService.showWarningMessage(with: "device_list_available_timeout".localized()) { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        CommunicationService.shared.stopDiscoveringNodes()
    }
    
    // MARK: IBActions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        CommunicationService.shared.stopDiscoveringNodes()
        dismiss(animated: true, completion: nil)
    }

}

extension DeviceListViewController {
    
    func configure(with toUpload: Uploadable) {
        self.toUpload = toUpload
    }
    
}

private extension DeviceListViewController {
    
    func askForUploadCurrentFlow(to node: BlueSTSDKNode) {
        print(node.friendlyName())
        
        ModalService.showAlert(with: "overwrite_board".localized(),
                               message: "warn_overvrite_message".localized(),
                               okTitle: "ok".localized(),
                               cancelTitle: "cancel".localized()) { [weak self] success in
                                if success {
                                    guard let self = self else { return }
                                    
                                    self.uploadCurrentFlow(to: node)
                                }
        }
        
    }
    
    func uploadCurrentFlow(to node: BlueSTSDKNode) {
        
        guard let toUpload = toUpload else {
            return
        }
        
        CommunicationService.shared.stopDiscoveringNodes()
        
        let controller: LoadingViewController = LoadingViewController.makeViewControllerFromNib()
        controller.configure(with: "uploading_your_flow".localized(), message: "upload_please_wait".localized())
        
        present(controller,
                animated: true) {
                    CommunicationService.shared.upload(toUpload: toUpload, to: node) { [weak self] error in
                        
                        guard let self = self else { return }
                        
                        self.dismiss(animated: true) {
                            switch error {
                            case .trasmission(let trasmissionError):
                                switch trasmissionError {
                                case .none:
                                    ModalService.showMessage(with: error.localizedDescription){ _ in
                                        guard let flows = toUpload as? Flows else{
                                            return
                                        }
                                        if flows.hasBLEOutput{
                                            NotificationCenter.default.post(name: .didUploadFlowsWithStreamOnBleOutput, object: nil)
                                        }
                                        if flows.hasSDOutput{
                                            ModalService.showMessage(with: "sd_recording_info_message".localized()){ _ in
                                                NotificationCenter.default.post(name: .didUploadFlowsWithStreamOnBleOutput, object: nil)
                                            }
                                        }
                                    }
                                    break
                                default:
                                    ModalService.showWarningMessage(with: error.localizedDescription)
                                }//switch transmission
                            default:
                                break
                    }//switch error
                }//dismiss
            }//upload
        }//present
    }

    
    
}

extension DeviceListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nodes.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DeviceCell.reusableIdentifier(), for: indexPath)
        
        if let cell = cell as? DeviceCell {
            let device = nodes[indexPath.row]
            cell.configure(with: device.friendlyName())
        }
        
        return cell
    }
}

extension DeviceListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let node = nodes[indexPath.row]
        askForUploadCurrentFlow(to: node)
    }
}
