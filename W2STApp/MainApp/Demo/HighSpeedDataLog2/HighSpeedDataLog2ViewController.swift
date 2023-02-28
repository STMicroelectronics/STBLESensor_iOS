//
//  HighSpeedDataLog2ViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

class HighSpeedDataLog2ViewController: BlueMSDemoTabViewController {
    enum Mode {
        case config
        case tag
    }
    
    private let tabbar = UIToolbar()
    private let containerView = UIView()

    private let configurationController = HighSpeedDataLog2ConfigurationViewController(PnPLikeService().currentPnPLDtmi())
    private let tagController = HighSpeedDataLog2TagViewController(PnPLikeService().currentPnPLDtmi())
    private let configButton = UIButton()
    private let tagButton = UIButton()

    
    private var mode = Mode.config {
        didSet {
            updateControllers()
        }
    }
    
    internal var tryToSwitchToTagOnStartPerformed = true
    
    override var node: BlueSTSDKNode {
        didSet {
            configurationController.node = node
            tagController.node = node
        }
    }
    
    override var menuDelegate: BlueSTSDKViewControllerMenuDelegate? {
        didSet {
            configurationController.menuDelegate = menuDelegate
            tagController.menuDelegate = menuDelegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tabbar, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.safeAreaLayoutGuide.bottomAnchor)
        ])
        view.addSubview(containerView, constraints: [
            equal(\.safeAreaLayoutGuide.topAnchor),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.bottomAnchor, toView: tabbar, withAnchor: \.topAnchor, constant: 0)
        ])
        
        configButton.setImage(UIImage.namedFromGUI("ic_gear")?.withRenderingMode(.alwaysTemplate), for: .normal)
        configButton.addTarget(self, action: #selector(switchToConfig), for: .touchUpInside)
        tagButton.setImage(UIImage.namedFromGUI("ic_play")?.withRenderingMode(.alwaysTemplate), for: .normal)
        tagButton.addTarget(self, action: #selector(switchToTag), for: .touchUpInside)
        
        tabbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: configButton),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(customView: tagButton),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        ]
        
        updateControllers()
    }
    
    private func setLoadingUIVisible(_ visible: Bool) {}
    
    private func updateControllers() {
        switch mode {
            case .config:
                tagController.removeFromParentController()
                add(child: configurationController, appendTo: containerView, atIndex: 0, constraints: UIView.fitToSuperViewConstraints)
            case .tag:
                configurationController.removeFromParentController()
                add(child: tagController, appendTo: containerView, atIndex: 0, constraints: UIView.fitToSuperViewConstraints)
        }

        updateUI()
    }
    
    private func updateUI() {
        switch mode {
            case .config:
                configButton.tintColor = currentTheme.color.primary
                tagButton.tintColor = .gray
                
            case .tag:
                configButton.tintColor = .gray
                tagButton.tintColor = currentTheme.color.primary
        }
    }
    
    @objc
    func switchToConfig() {
        setLoadingUIVisible(false)
        mode = .config
    }
    
    @objc
    func switchToTag() {
        tryToSwitchToTagOnStartPerformed = false
        
        setLoadingUIVisible(false)
        mode = .tag
    }
}
