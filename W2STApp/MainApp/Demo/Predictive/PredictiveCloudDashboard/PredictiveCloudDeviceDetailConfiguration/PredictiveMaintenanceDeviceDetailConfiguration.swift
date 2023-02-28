//
//  PredictiveMaintenanceDeviceDetailConfiguration.swift
//  W2STApp

import Foundation
import STTheme
import CoreData
import SwiftyJSON

public struct PMSettings {
    public let settingImage: String
    public let settingName: String
    public let settingDescription: String
}

class PredictiveMaintenanceDeviceDetailConfiguration: UIViewController {
    private let tableView = UITableView(frame: .zero, style: .plain)
    
    var pmCloudDeviceCertificates = [PMCloudDevice]()
    var container: NSPersistentContainer!
    
    var nodeID: String
    
    public let settings: [PMSettings] = [
        PMSettings(settingImage: "st_wifi", settingName: "WiFi Settings", settingDescription: "Set Board WiFi parameters."),
        PMSettings(settingImage: "st_traditional_key", settingName: "Send Certificate to the node", settingDescription: "Send the certificate (provided by the dashboard during provisioning) to the board.")
    ]
    
    private let node: BlueSTSDKNode
    
    init(node: BlueSTSDKNode, nodeID: String) {
        self.node = node
        self.nodeID = nodeID
        super.init(nibName: nil, bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func dismissController() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = NSPersistentContainer(name: "PMCloudDeviceCertificate")

        container.loadPersistentStores { storeDescription, error in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        title = "Settings"
        view.backgroundColor = currentTheme.color.background
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissController))

        tableView.register(PredictiveDeviceDetailTableViewCell.self, forCellReuseIdentifier: PredictiveDeviceDetailTableViewCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubviewAndFit(tableView)
        
        reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIButton.appearance().setTitleColor(.white, for: .normal)
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //  Reset button styles
        ThemeService.shared.applyToAllViewType()
    }
    
    private func reloadData() {
        self.tableView.reloadData()
    }
}

extension PredictiveMaintenanceDeviceDetailConfiguration: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PredictiveDeviceDetailTableViewCell.reuseIdentifier, for: indexPath) as? PredictiveDeviceDetailTableViewCell else { return UITableViewCell() }
        
        let setting = settings[indexPath.row]
        
        cell.configure(settingImage: setting.settingImage, settingName: setting.settingName, settingDescription: setting.settingDescription)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        if(index==0){
            UpdateWifiSettingsViewController.presentFrom(viewController: self, security: "OPEN") { [weak self] wifisettings in
                self?.sendWiFiSettings(wifisettings)
            }
            tableView.deselectRow(at: indexPath, animated: true)
        }else{
            tableView.deselectRow(at: indexPath, animated: true)
            loadSavedData()
            
            var lastPMCloudDevice: PMCloudDevice? = nil
            
            pmCloudDeviceCertificates.forEach{ device in
                if(nodeID == device.id){
                    lastPMCloudDevice = device
                }
            }
            
            guard let lastPMCloudDevice = lastPMCloudDevice else { return }
            
            guard let json = buildPMCloudDeviceCert(pmCloudDevice: lastPMCloudDevice) else { return }
            print("sending certificate: \(json)")
            feature?.sendCommand(.setCert, string: json)
            view.makeToast("Certificate sent to the board.")
        }
    }
    
    private func buildPMCloudDeviceCert(pmCloudDevice: PMCloudDevice) -> String? {
        let param1 : [String: String?] = ["Certificate": pmCloudDevice.certificate]
        let param2 : [String: String?] = ["DeviceId":pmCloudDevice.id]
        let param3 : [String: String?] = ["PrivateKey":pmCloudDevice.key]
        
        var jsonString: String? = nil

        do {
            let data1 = try JSONSerialization.data(withJSONObject: param1, options: JSONSerialization.WritingOptions()) as NSData
            let data2 = try JSONSerialization.data(withJSONObject: param2, options: JSONSerialization.WritingOptions()) as NSData
            let data3 = try JSONSerialization.data(withJSONObject: param3, options: JSONSerialization.WritingOptions()) as NSData
            
            var string1 = NSString(data: data1 as Data, encoding: String.Encoding.utf8.rawValue)! as String
            var string2 = NSString(data: data2 as Data, encoding: String.Encoding.utf8.rawValue)! as String
            var string3 = NSString(data: data3 as Data, encoding: String.Encoding.utf8.rawValue)! as String
            
            string1.removeFirst()
            string1.removeLast()
            
            string2.removeFirst()
            string2.removeLast()
            
            string3.removeFirst()
            string3.removeLast()
            
            jsonString = "{\(string1),\(string2),\(string3)}"
            
            return jsonString
        } catch _ {
            print ("JSON Failure")
            return nil
        }
    }
    
    internal func sendWiFiSettings(_ wifisettings: WiFiSettings) {
        feature?.sendCommand(.setWiFi, json: wifisettings)
        view.makeToast("Wi-Fi Credential Sent to Board.")
    }
    
    internal var feature: BlueSTSDKFeatureExtendedConfiguration? {
        node.getFeatureOfType(BlueSTSDKFeatureExtendedConfiguration.self) as? BlueSTSDKFeatureExtendedConfiguration
    }
    
    func loadSavedData() {
        let request = PMCloudDevice.createFetchRequest()
        let sort = NSSortDescriptor(key: "id", ascending: false)
        request.sortDescriptors = [sort]
        do {
            pmCloudDeviceCertificates = try container.viewContext.fetch(request)
        } catch {
            print("Fetch failed")
        }
    }
}
