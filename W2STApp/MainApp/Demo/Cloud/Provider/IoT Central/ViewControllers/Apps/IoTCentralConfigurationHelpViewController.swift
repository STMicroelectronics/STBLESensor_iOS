//
//  IoTCentralSharableLinksViewController.swift
//
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import Foundation
import UIKit
import BlueSTSDK_Gui

class IoTCentralConfigurationHelpViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let saveButton = UIButton()
    
    private var mainStack: UIStackView!
    
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let stepsLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = currentTheme.color.background
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissModal))
        
        mainStack = UIStackView.getVerticalStackView(withSpacing: 24, views: [
            titleLabel,
            descriptionLabel,
            stepsLabel
        ])
        
        
        let containerView = UIView()
        
        scrollView.addSubview(containerView, constraints: [
            equal(\.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor)
        ])
        
        containerView.addSubview(mainStack, constraints: [
            equal(\.topAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        view.addSubview(saveButton, constraints: [
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            equalDimension(\.heightAnchor, to: 44)
        ])
        
        view.addSubview(scrollView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor, toView: saveButton, withAnchor: \.topAnchor, constant: -16)
        ])
        
        containerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        scrollView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
        
        /**SAVE Button that allows you to save information about your Azure IoT Central Application */
        saveButton.backgroundColor = currentTheme.color.primary
        saveButton.cornerRadius = 12
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitle("CLOSE", for: .normal)
        saveButton.onTap { [weak self] _ in
            self?.dismissModal()
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
        descriptionLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        stepsLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        /*[titleLabel, descriptionLabel].forEach { view in
            view.textColor = .white
        }*/
        
        
        titleLabel.text = "Help"
        
        descriptionLabel.text = "Follow the instructions below to configure Azure Iot Central application:"
        
        /*descriptionLabel.text = "You don’t know what to put in the \"APP NAME\" and \"API TOKEN\" fields? \nFollow the instructions below And configure your Azure Iot Central application!"*/
        
        stepsLabel.text = "1. Send Sharable Link to your mail.\n\n2. Open the link in a web browser on your PC. \n\n3. Sign in with your Microsoft account. \n\n4. Name the application you’re replicating in your account and choose your plan. \n\n5. Create a new token: \nAdministration ➾ Token API ➾ New. \n\n6. Now you can scan the QR Code through the ST BLE Sensor app and enter in the field \"APP NAME\" the name you chose before."
        
        /*stepsLabel.text = "1. Send Sharable Link to your mail.\n\n2. Open the link in a web browser on your PC. \n\n3. Sign in with your Microsoft account. \n\n4. Name the application you’re replicating in your account and choose your plan. \n\n5. Create a new token: \nAdministration ➾ Token API ➾ New. \n\n6. Now you can scan the QR Code generated through the ST BLE Sensor app to get the token and enter in the field \"APP NAME\" the name you chose before."*/
        
        titleLabel.numberOfLines = 2
        descriptionLabel.numberOfLines = 10
        stepsLabel.numberOfLines = 40
    }
    
    @objc
    private func dismissModal() {
        dismiss(animated: true)
    }
}
