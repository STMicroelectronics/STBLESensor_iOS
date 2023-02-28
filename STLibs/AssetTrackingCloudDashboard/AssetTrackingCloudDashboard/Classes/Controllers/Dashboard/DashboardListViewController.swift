//
//  DashboardListViewController.swift
//  AssetTrackingCloudDashboard
//
//  Created by Klaus Lanzarini on 09/10/2020.
//

import UIKit
import AssetTrackingDataModel
import PKHUD

class DashboardListViewController: UIViewController {
    lazy var tableView: UITableView = UITableView()
    
    var elements: [AssetTrackingDevice] = [] {
        didSet { DispatchQueue.main.async { self.tableView.isHidden = self.elements.count == 0 } }
    }
    
    private let deviceManager: DeviceManager
    
    init(deviceManager: DeviceManager) {
        self.deviceManager = deviceManager
        super.init(nibName: nil, bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Devices"
        view.backgroundColor = .white
        
        removeLoginFromNavigation()
        setupTable()
        
        HUD.show(.progress, onView: self.view)
        loadDevices { [weak self] devices in
            self?.elements = devices.filter { $0.deviceType == .ASTRA || $0.deviceType == .NFCTAG2
                || $0.deviceType == .NFCTAG1 || $0.deviceType == .SENSORTILEBOX }
            
            DispatchQueue.main.async {
                HUD.hide()
                self?.tableView.reloadData()
            }
        }
    }
}

private extension DashboardListViewController {
    func removeLoginFromNavigation() {
        guard let navigationController = navigationController else { return }
        var viewControllers = navigationController.viewControllers
        
        if let match = viewControllers.enumerated().first(where: { $0.element is AssetTrackingLoginViewController }) {
            viewControllers.remove(at: match.offset)
            navigationController.setViewControllers(viewControllers, animated: false)
        }
    }
    
    func loadDevices(completion: @escaping ([AssetTrackingDevice]) -> Void) {
        deviceManager.listDevices { [weak self] result in
            switch result {
            case .success(let devices):
                completion(devices)
            case .failure(let error):
                break
            }
        }
    }
    
    func setupTable() {
        let emptyViewLabel = UILabel()
        emptyViewLabel.text = "No devices"
        emptyViewLabel.font = UIFont.boldSystemFont(ofSize: 18)
        
        view.addSubview(emptyViewLabel)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyViewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyViewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyViewLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 89
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(DashboardListTableViewCell.self, forCellReuseIdentifier: DashboardListTableViewCell.reuseIdentifier)
    }
}

extension DashboardListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DashboardListTableViewCell.reuseIdentifier, for: indexPath) as? DashboardListTableViewCell else { return UITableViewCell() }
        let element = elements[indexPath.row]
        
        cell.configure(name: element.label ?? element.id,
                       date: "", // "Last sync: \(element.lastSync)"
                       image: (configureDeviceTypeImage(element: element)))
        
        return cell
    }
    
    func configureDeviceTypeImage(element: AssetTrackingDevice) -> String{
        if (element.isAstra || element.isSensorTileBox) {
            return "ic_bluetooth"
        } else if (element.isNfcTag1 || element.isNfcTag2) {
            return "ic_nfctag"
        } else {
            return "ic_bluetooth"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = elements[indexPath.row]
        let vc = DashboardDetailViewController(deviceManager: deviceManager, deviceId: device.id)
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
