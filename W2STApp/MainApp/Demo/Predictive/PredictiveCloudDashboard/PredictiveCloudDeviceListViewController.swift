//
//  PredictiveCloudDeviceListViewController.swift
//  W2STApp

import Foundation
import BlueSTSDK
import BlueSTSDK_Gui
import PKHUD
import Alamofire
import STTheme
import AssetTrackingCloudDashboard

class PredictiveCloudDeviceListViewController: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let noDataLabel = UILabel()
    
    private var nodeID = ""
    private let node: BlueSTSDKNode
    var elements = [PMRemoteDevices]()
    
    private var pmServices: PredictiveMaintenanceCloudServices
    
    private var completeDebugMsgOutput = ""
    
    private var extFeature: BlueSTSDKFeatureExtendedConfiguration? {
        node.getFeatureOfType(BlueSTSDKFeatureExtendedConfiguration.self) as? BlueSTSDKFeatureExtendedConfiguration
    }
    
    init(node: BlueSTSDKNode) {
        let idTokenN = UserDefaults.standard.string(forKey: "PMidTokenN")
        let accessTokenN = UserDefaults.standard.string(forKey: "PMaccessTokenN")
        self.node = node
        self.pmServices = PredictiveMaintenanceCloudServices(idTokenN: idTokenN, accessTokenN: accessTokenN)

        super.init(nibName: nil, bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func dismissController() {
        dismiss(animated: true)
    }
    
    @objc
    private func addPMDevice() {
        let controller = PredictiveCloudAddNewDeviceViewController(node: node, deviceName: node.name, deviceID: nodeID, pmServices: pmServices)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let feature = extFeature {
            feature.add(self)
            feature.enableNotification()
            feature.sendCommand(ECCommandType.UID)
        } else {
            node.debugConsole?.add(self)
            node.debugConsole?.writeMessage("uid\n")
        }
        
        title = "Devices"
        view.backgroundColor = currentTheme.color.background
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPMDevice))
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissController))
        noDataLabel.text = "No Devices provisioned"
        noDataLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        noDataLabel.numberOfLines = 0
        noDataLabel.textAlignment = .center
        tableView.register(PredictiveDeviceTableViewCell.self, forCellReuseIdentifier: PredictiveDeviceTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        noDataLabel.isHidden = true
        
        view.addSubviewAndFit(noDataLabel, top: 16, trailing: 16, bottom: 16, leading: 16)
        view.addSubviewAndFit(tableView)
        
       
        reloadModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIButton.appearance().setTitleColor(.white, for: .normal)
        reloadModel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //  Reset button styles
        ThemeService.shared.applyToAllViewType()
    }
    
    private func reloadModel() {
        HUD.show(.progress, onView: self.view)
        pmServices.getPMdevices { devices,error in
            self.elements = devices
            DispatchQueue.main.async {
                HUD.hide()
                self.tableView.reloadData()
                self.noDataLabel.isHidden = !self.elements.isEmpty
                self.tableView.isHidden = self.elements.isEmpty
            }
        }
    }
    
    private func deletePMDevice(_ device: PMRemoteDevices) {
        func deleteApp() {
            pmServices.deletePMDevice(thingName: device.thingName!, { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(error)
                } else {
                    self?.showDoneAlert(operationMessage: "Device Deleted.")
                    self?.reloadModel()
                }
            })
        }
        
        UIAlertController.presentAlert(from: self, title: "Are you sure to delete this device?", message: nil, actions: [
            UIAlertAction.destructiveButton("generic.yes".localizedFromGUI, { _ in
                deleteApp()
            }),
            UIAlertAction.cancelButton()
        ])
    }
    
    private func setDeviceID(_ id: String) {
        nodeID = id
    }
    
    private func showErrorAlert(_ error: Error) {
        UIAlertController.presentAlert(from: self, title: "Error", message: error.localizedDescription, actions: [UIAlertAction.genericButton()])
    }
    
    private func showDoneAlert(operationMessage: String) {
        UIAlertController.presentAlert(from: self, title: "Operation complete.", message: operationMessage, actions: [UIAlertAction.genericButton()])
    }
}

extension PredictiveCloudDeviceListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PredictiveDeviceTableViewCell.reuseIdentifier, for: indexPath) as? PredictiveDeviceTableViewCell else { return UITableViewCell() }
        let element = elements[indexPath.row]
        
        cell.configure(name: element.attributes?.assetname ?? " ", id: element.thingName ?? " ", nodeID: nodeID)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PredictiveMaintenanceDeviceDetailConfiguration(node: node, nodeID: nodeID)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return [
            UITableViewRowAction(style: .destructive, title: "Delete", handler: { [unowned self] _, indexPath in
                self.deletePMDevice(elements[indexPath.row])
            })
        ]
    }
}


extension PredictiveCloudDeviceListViewController: BlueSTSDKFeatureDelegate {
    private func manageResponse(response: ECResponse) {
        guard let type = response.type else { return }
        switch type {
            case .UID:
                if let id = response.UID { setDeviceID(id) }
            default:
                break
        }
    }
    
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        DispatchQueue.main.async {
            if let sample = sample as? ECFeatureSample {
                self.manageResponse(response: sample.response)
            }
        }
    }
}

extension PredictiveCloudDeviceListViewController: BlueSTSDKDebugOutputDelegate {
    func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        
        if(!(msg.hasSuffix("\n"))){
            completeDebugMsgOutput = completeDebugMsgOutput + msg
            return
        }else{
            completeDebugMsgOutput = completeDebugMsgOutput + msg
        }
        
        let parts = completeDebugMsgOutput.split(separator: "_")
        
        if let id = parts.first {
            setDeviceID(String(id).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        }
    }
    
    func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {
        //debugPrint("didStdErrReceived: \(msg)")
    }
    func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        //debugPrint("didStdInSend: \(msg)")
    }
}

/** Reusable Cell */
protocol ReusableView {
    static var reuseIdentifier: String { get }
}

extension ReusableView {
    static var reuseIdentifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReusableView {}

extension UICollectionViewCell: ReusableView {}
