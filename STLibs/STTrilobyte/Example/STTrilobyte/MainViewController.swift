//
//  MainViewController.swift
//  trilobyte-ios
//
//  Created by Stefano Zanetti on 23/01/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit
import STTrilobyte

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func openSensorTile101ButtonPressed(_ sender: Any) {
        let controller: SensorTile101ViewController = SensorTile101ViewController()
        controller.sensorTile101Delegate = self
        navigationController?.pushViewController(controller, animated: true)
        
    }
}

extension MainViewController: SensorTile101Delegate {
    
    func didUploadFlowsWithBleStreamOutput(controller: SensorTile101ViewController) {
        print("Bluetooth notification received")
    }
    
}
