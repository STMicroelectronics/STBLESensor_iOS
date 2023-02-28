//
//  HighSpeedDataLogTagViewController.swift
//  W2STApp
//
//  Created by Dimitri Giani on 29/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

class HighSpeedDataLogTagViewController: HighSpeedDataLogBaseViewController {
    static let maxLabelNameCount = 20
    static let maxAcquisitionNameCount = 14
    static let maxAcquisitionDescriptionCount = 99
    
    enum Cell {
        case software(_ tag: HSDTag)
        case hardware(_ tag: HSDTag)
    }
    
    enum State {
        case waiting
        case logging
    }
    
    internal let acquisitionNameTextField = LimitedTextField(limit: HighSpeedDataLogTagViewController.maxAcquisitionNameCount)
    internal let acquisitionDescriptionTextField = LimitedTextField(limit: HighSpeedDataLogTagViewController.maxAcquisitionDescriptionCount)
    internal let actionButton = UIButton()
    internal let selectAllDescriptionLabel = UILabel()
    internal let selectAllLabel = UILabel()
    internal let selectAllSwitch = UISwitch()
    internal let tableView = UITableView()
    internal var selectAllStackView: UIStackView!
    internal var acquisitionDataStackView: UIStackView!
    internal var enabledTags: Set<HSDTag> = []
    internal var taggingEnabledTags: Set<HSDTag> = []
    internal var state: State = .waiting {
        didSet {
            updateUI()
        }
    }
    
    internal var tagConfig: HSDTagConfig? {
        feature?.tagConfig
    }
    
    internal var isSDCardInserted: Bool = false
    internal var tags: [Cell] = []
    internal var loggingTags: [Cell] {
        var model: [Cell] = []
        model.append(contentsOf: enabledTags.filter { $0.type == .software }.sorted(by: { $0.label < $1.label }).map { Cell.software($0) })
        model.append(contentsOf: enabledTags.filter { $0.type == .hardware }.sorted(by: { $0.label < $1.label }).map { Cell.hardware($0) })
        
        return model
    }
    internal var modelTags: [Cell] {
        switch state {
            case .waiting:
                return tags
                
            case .logging:
                return loggingTags
        }
    }
    
    override func setupUI() {
        super.setupUI()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.rowHeight = UITableView.automaticDimension
        
        acquisitionNameTextField.setDimensionContraints(width: nil, height: 44)
        acquisitionDescriptionTextField.setDimensionContraints(width: nil, height: 44)
        acquisitionNameTextField.borderStyle = .roundedRect
        acquisitionDescriptionTextField.borderStyle = .roundedRect
        acquisitionNameTextField.placeholder = "hsd_tag_acquisition_name_placeholder".localizedFromGUI
        acquisitionDescriptionTextField.placeholder = "hsd_tag_acquisition_description_placeholder".localizedFromGUI
        
        actionButton.cornerRadius = 4
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.setTitleColor(.white, for: .disabled)
        actionButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        actionButton.addTarget(self, action: #selector(toggleLogging), for: .touchUpInside)
        
        selectAllDescriptionLabel.text = "hsd.tag.select_all.description".localizedFromGUI
        selectAllLabel.text = "hsd.tag.select_all".localizedFromGUI
        selectAllSwitch.onTintColor = currentTheme.color.secondary
        selectAllDescriptionLabel.textColor = currentTheme.color.primary
        selectAllLabel.textColor = currentTheme.color.primary
        selectAllDescriptionLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        selectAllLabel.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        selectAllSwitch.isOn = true
        selectAllSwitch.addTarget(self, action: #selector(selectAllDidChange), for: .valueChanged)
        
        selectAllStackView = UIStackView.getHorizontalStackView(withSpacing: 4, views: [
            selectAllDescriptionLabel, selectAllLabel, selectAllSwitch
        ])
        
        acquisitionDataStackView = UIStackView.getVerticalStackView(withSpacing: 4, views: [acquisitionNameTextField, acquisitionDescriptionTextField])
        
        view.addSubview(acquisitionDataStackView, constraints: [
            equal(\.topAnchor, toView: headerView, withAnchor: \.bottomAnchor, constant: 0),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])
        view.addSubview(selectAllStackView, constraints: [
            equal(\.topAnchor, toView: acquisitionDataStackView, withAnchor: \.bottomAnchor, constant: 4),
            equal(\.leadingAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16)
        ])
        view.addSubview(tableView, constraints: [
            equal(\.topAnchor, toView: selectAllStackView, withAnchor: \.bottomAnchor, constant: 4),
            equal(\.leadingAnchor),
            equal(\.trailingAnchor)
        ])
        view.addSubview(actionButton, constraints: [
            equal(\.topAnchor, toView: tableView, withAnchor: \.bottomAnchor, constant: 16),
            equal(\.trailingAnchor, constant: -16),
            equal(\.bottomAnchor, constant: -16)
        ])
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if tags.isEmpty {
            reloadModel()
        }
        
        //  Check status on appear.
        //  If app was closed, here I check status when launched.
        if deviceStatus?.isLogging == true {
            state = .logging
        }
        
        updateUI()
    }
    
    override func setLoadingUIVisible(_ visible: Bool, text: String = "") {
        super.setLoadingUIVisible(visible, text: text)
        
        actionButton.isHidden = visible
        acquisitionDataStackView.isHidden = visible
        selectAllStackView.isHidden = visible
        tableView.isHidden = visible
    }
    
    override func updateUI() {
        super.updateUI()
        
        tableView.reloadData()
        selectAllStackView.isHidden = isLogging
        tableView.isHidden = isLogging && loggingTags.isEmpty
        
        updateActionButton()
    }
    
    private func updateActionButton() {
        if let isSDInserted = deviceStatus?.isSDInserted { self.isSDCardInserted = isSDInserted }
        
        if !isSDCardInserted {
            actionButton.isEnabled = false
            actionButton.backgroundColor = .lightGray
            actionButton.setTitle("hsd.tag.startbutton.nocard".localizedFromGUI.uppercased(), for: .normal)
        } else {
            actionButton.isEnabled = true
            actionButton.backgroundColor = currentTheme.color.primary
            if state == .logging {
                actionButton.setTitle("hsd.tag.startbutton.stop".localizedFromGUI.uppercased(), for: .normal)
            } else {
                actionButton.setTitle("hsd.tag.startbutton.start".localizedFromGUI.uppercased(), for: .normal)
            }
        }
    }
    
    private func prepareModel() {
        updateTagsForSelectAllAction()
        
        var model: [Cell] = []
        model.append(contentsOf: tagConfig?.swTags.map { Cell.software($0) }  ?? [] )
        model.append(contentsOf: tagConfig?.hwTags.map { Cell.hardware($0) }  ?? [] )
        
        tags = model
    }
    
    private func reloadModel() {
        let tagsAreEmpty = model?.tagConfig.hwTags.isEmpty == true || model?.tagConfig.hwTags == nil
        if tagsAreEmpty {
            setLoadingUIVisible(true)
            
            //  Wait a second before send command, otherwise the board do not receive the command
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.feature?.sendGetCommand(HSDGetCmd.TagConfig)
                self.prepareModel()
                self.updateUI()
            }
        } else {
            prepareModel()
            updateUI()
        }
    }
    
    @objc func selectAllDidChange() {
        updateTagsForSelectAllAction()
    }
    
    @objc
    internal func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc
    internal func toggleLogging() {
        switch state {
            case .waiting:
                startLogging()
            case .logging:
                stopLogging()
        }
    }
    
    internal func updateTagsForSelectAllAction() {
        //  Get all HW Tags enabled and disable from the board
        enabledTags.filter { tagConfig?.hwTags.contains($0) == true }.forEach {
            feature?.sendSetCommand(HSDSetHWTagCmd(ID: $0.id, enable: false)) {}
        }
        
        //  Empty Tags
        enabledTags = []
        
        //  If isOn, select all
        if selectAllSwitch.isOn {
            selectAllSwitch.isOn = true
            
            tagConfig?.swTags.forEach { enabledTags.insert($0) }
            tagConfig?.hwTags.forEach { enabledTags.insert($0) }
            
            //  HW Tags needs to be enabled in the board
            tagConfig?.hwTags.forEach {
                feature?.sendSetCommand(HSDSetHWTagCmd(ID: $0.id, enable: true)) {}
            }
        }
        
        tableView.reloadData()
    }
    
    internal func didChangeEnabledTag(_ tag: HSDTag, enabled: Bool) {
        if state == .waiting {
            if enabled {
                enabledTags.insert(tag)
            } else {
                enabledTags.remove(tag)
            }
        } else {
            if enabled {
                taggingEnabledTags.insert(tag)
            } else {
                taggingEnabledTags.remove(tag)
            }
        }
        
        switch tag.type {
            case .software:
                if state == .logging {
                    feature?.sendSetCommand(HSDSetSWTagCmd(ID: tag.id, enable: enabled)) {}
                }
                
            case .hardware:
                feature?.sendSetCommand(HSDSetHWTagCmd(ID: tag.id, enable: enabled)) {}
                
            case .none:
                break
        }
        
        updateUI()
    }
    
    internal func didWantEditTag(_ tag: HSDTag) {
        var textField: UITextField?
        
        UIAlertController.presentTextFieldAlert(from: self,
                                                title: "hsd.tag.edittagname.title".localizedFromGUI,
                                                confirmButton: UIAlertAction(title: "generic.apply".localizedFromGUI, style: .default, handler: { [weak self] _ in
                                                    
                                                    if let text = textField?.text, !text.isEmpty {
                                                        self?.setUpdateTagLabel(tag, label: String(text.prefix(HighSpeedDataLogTagViewController.maxLabelNameCount)))
                                                    }
                                                    
                                                })) { aTextField, _ in
            textField = aTextField
            textField?.text = tag.label
        }
    }
    
    internal func removeTagAtIndex(_ index: Int) {
        tags.remove(at: index)
        tableView.reloadData()
    }
    
    internal func setUpdateTagLabel(_ tag: HSDTag, label: String) {
        tag.label = label
        switch tag.type {
            case .software:
                feature?.sendSetCommand(HSDSetSWTagLabelCmd(ID: tag.id, label: label)) {}
            case .hardware:
                feature?.sendSetCommand(HSDSetHWTagLabelCmd(ID: tag.id, label: label)) {}
            case .none:
                break
        }
        
        tableView.reloadData()
    }
    
    internal func startLogging() {
        guard state == .waiting else { return }
        
        isLogging = true
        taggingEnabledTags = []
        
        feature?.sendSetCommand(HSDSetAcquisitionInfoCmd(name: acquisitionNameTextField.text, notes: acquisitionDescriptionTextField.text)) {}
        feature?.sendControlCommand(HSDControlCmd.StartLogging)
        
        state = .logging
    }
    
    internal func stopLogging() {
        guard state == .logging else { return }
        
        isLogging = false
        feature?.sendControlCommand(HSDControlCmd.StopLogging)
        
        state = .waiting
        
        taggingEnabledTags = []
    }
    
    override func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        super.didUpdate(feature, sample: sample)
        
        DispatchQueue.main.async {
            if let sample = sample as? ConfigSample, sample.tagConfig != nil {
                self.setLoadingUIVisible(false)
                self.prepareModel()
                self.updateUI()
            }
            
            self.updateActionButton()
        }
    }
}

class LimitedTextField: UITextField {
    private let limit: Int
    init(limit: Int) {
        self.limit = limit
        
        super.init(frame: .zero)
        
        delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= limit
    }

}
