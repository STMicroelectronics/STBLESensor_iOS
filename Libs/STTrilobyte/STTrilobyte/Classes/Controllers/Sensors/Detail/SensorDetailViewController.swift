//
//  SensorDetailViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 08/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class SensorDetailViewController: BaseViewController {
    
    @IBOutlet weak var sensorImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    var sensor: Sensor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "sensor".localized()
        
        configureView()
    }
    
    func configure(with sensor: Sensor) {
        self.sensor = sensor
    }
}

private extension SensorDetailViewController {
    
    func configureView() {
        
        guard let currentSensor = sensor else { return }
        
        titleLabel.font = currentTheme.font.bold.withSize(16.0)
        titleLabel.textColor = currentTheme.color.textDark
        titleLabel.text = currentSensor.descr
        
        sensorImage.image = UIImage.named(currentSensor.icon)
        
        let outputRow: PropertyRow = PropertyRow.createFromNib()
        outputRow.configure(property: "output".localized(), value: currentSensor.output)
        stackView.addArrangedSubview(outputRow)
        
        if let uom = currentSensor.uom {
            let unitRow: PropertyRow = PropertyRow.createFromNib()
            unitRow.configure(property: "unit".localized(), value: uom)
            stackView.addArrangedSubview(unitRow)
        }
        
        let propertiesRow: PropertyRow = PropertyRow.createFromNib()
        propertiesRow.configure(property: "properties".localized(), value: currentSensor.description)
        stackView.addArrangedSubview(propertiesRow)
        
        if let notes = currentSensor.notes {
            let descriptionRow: PropertyRow = PropertyRow.createFromNib()
            descriptionRow.configure(property: "notes".localized(), value: notes)
            stackView.addArrangedSubview(descriptionRow)
        }
        
        let modelRow: PropertyRow = PropertyRow.createFromNib()
        modelRow.configure(property: "model".localized(), value: currentSensor.model)
        stackView.addArrangedSubview(modelRow)
        
        if let datasheet = currentSensor.datasheetLink {
            let descriptionRow: PropertyRow = PropertyRow.createFromNib()
            descriptionRow.configure(property: "datasheet".localized(), link: datasheet)
            stackView.addArrangedSubview(descriptionRow)
        }
    }
}
