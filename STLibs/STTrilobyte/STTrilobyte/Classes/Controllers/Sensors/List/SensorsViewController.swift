//
//  SensorsViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 07/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class SensorsViewController: BaseViewController {
    
    var sensors = [Sensor]()
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "navigation_title_sensors".localized()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerClassCell(SensorCell.self)
        
        sensors = PersistanceService.shared.getAllSensors()
        
        configure()
    }
    
}

private extension SensorsViewController {
    
    func configure() {
        view.backgroundColor = currentTheme.color.background
        
        titleLabel.text = "sensors_title".localized()
        titleLabel.font = currentTheme.font.bold.withSize(24.0)
        titleLabel.textColor = currentTheme.color.primary
        
        subtitleLabel.text = "sensors_subtitle".localized()
        subtitleLabel.font = currentTheme.font.regular.withSize(16.0)
        subtitleLabel.textColor = currentTheme.color.text
    }
}

extension SensorsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sensor = sensors[indexPath.row]
        let controller: SensorDetailViewController = SensorDetailViewController.makeViewControllerFromNib()
        controller.configure(with: sensor)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension SensorsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SensorCell.reusableIdentifier(), for: indexPath)
        
        if let cell = cell as? SensorCell {
            cell.configure(with: sensors[indexPath.row])
        }
        
        return cell
        
    }
}
