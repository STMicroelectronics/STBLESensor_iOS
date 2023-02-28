//
//  HighSpeedDataLogViewController.swift
//  W2STApp
//
//  Created by Klaus Lanzarini on 23/12/20.
//  Copyright © 2020 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

class HighSpeedDataLogViewController: BlueMSDemoTabViewController {
    enum Mode {
        case config
        case tag
    }
    
    private let tabbar = UIToolbar()
    private let containerView = UIView()
    private let configurationController = HighSpeedDataLogConfigurationViewController()
    private let tagController = HighSpeedDataLogTagViewController()
    private let configButton = UIButton()
    private let tagButton = UIButton()
    private var saveConfigMenuAction: UIAlertAction!
    private var loadConfigMenuAction: UIAlertAction!
    private var changeAliasMenuAction: UIAlertAction!
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
        
        /** Alert the user of possible problems with the old firmware of High Speed Datalog */
        alertHSDfwIssue()
        
        saveConfigMenuAction = UIAlertAction(title: "hsd_save_configuration".localizedFromGUI, style: .default, handler: { [weak self] _ in
            self?.configurationController.saveConfig()
        })
        
        loadConfigMenuAction = UIAlertAction(title: "hsd_load_configuration".localizedFromGUI, style: .default, handler: { [weak self] _ in
            self?.configurationController.chooseConfigJSON()
        })
        
        changeAliasMenuAction = UIAlertAction(title: "hsdl_changeAlias".localizedFromGUI, style: .default, handler: { [weak self] _ in
            self?.configurationController.changeAlias()
        })
        
        configurationController.didChangeLoadingState = { [weak self] isLoading in
            self?.setLoadingUIVisible(isLoading)
        }
        
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
    
    private func alertHSDfwIssue(){
        let defaults = UserDefaults.standard
        
        let alertShowed = defaults.bool(forKey: "HSDalert")
        
        if !(alertShowed){
            let alert = UIAlertController(title: "High Speed Datalog firmware version", message: "Please check your High Speed Datalog firmware version. if you have v1.1.0, something may not work. Please update to the latest version (https://www.st.com/en/embedded-software/fp-sns-datalog1.html)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                defaults.set(true, forKey: "HSDalert")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func updateMenu() {
        switch mode {
            case .config:
                menuDelegate?.addMenuAction(saveConfigMenuAction, atIndex: 0)
                menuDelegate?.addMenuAction(loadConfigMenuAction, atIndex: 1)
                menuDelegate?.addMenuAction(changeAliasMenuAction, atIndex: 2)
            case .tag:
                menuDelegate?.removeMenuAction(saveConfigMenuAction)
                menuDelegate?.removeMenuAction(loadConfigMenuAction)
                menuDelegate?.removeMenuAction(changeAliasMenuAction)
        }
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
        
        updateMenu()
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
