//
//  HSDCharacteristicDetailView.swift
//  W2STApp
//
//  Created by Dimitri Giani on 14/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import STTheme

class HSDCharacteristicDetailView: BaseView {
    private let titleLabel = UILabel()
    private let switchLabel = UILabel()
    private let checkView = UISwitch()
    private let configButton = UIButton()
    private let iconImageView = UIImageView()
    private var charTypeView = UIStackView()
    private let ucfLabel = UIButton()
    
    var switchDidChangeValue: (HSDSensorTouple, Bool)->() = { _, _ in }
    var charTypeOptionWantShowValues: (HSDOptionModel)->() = { _ in }
    var didTapLoadConfiguration: (HSDSensorTouple)->() = { _ in }
    var model: (sensor: HSDSensor, touple: HSDSensorTouple)! {
        didSet {
            updateUI()
        }
    }
    
    override func configureView() {
        super.configureView()
        
        charTypeView.axis = .vertical
        charTypeView.spacing = 8
        
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        titleLabel.textColor = .gray
        switchLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        switchLabel.text = "generic.enable".localizedFromGUI
        checkView.onTintColor = ThemeService.shared.currentTheme.color.secondary
        checkView.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)
        ucfLabel.clipsToBounds = true
        ucfLabel.cornerRadius = 15
        ucfLabel.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        ucfLabel.titleLabel?.textAlignment = .center
        ucfLabel.isUserInteractionEnabled = false
        ucfLabel.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
        ucfLabel.setDimensionContraints(width: nil, height: 30)
        
        configButton.addTarget(self, action: #selector(loadConfiguration), for: .touchUpInside)
        configButton.setTitleColor(ThemeService.shared.currentTheme.color.primary, for: .normal)
        
        iconImageView.setDimensionContraints(width: 44, height: 44)
        
        let switchStack = UIStackView.getHorizontalStackView(withSpacing: 2, views: [switchLabel, checkView])
        let headerView = UIStackView.getHorizontalStackView(withSpacing: 4, views: [titleLabel, switchStack])
        addSubview(headerView, constraints: [
            equal(\.topAnchor, constant: 6),
            equal(\.leadingAnchor, constant: 12),
            equal(\.trailingAnchor, constant: -12)
        ])
        
        addSubview(iconImageView, constraints: [
            equal(\.topAnchor, toView: headerView, withAnchor: \.bottomAnchor, constant: 6),
            equal(\.leadingAnchor, constant: 12)
        ])
        
        addSubview(charTypeView, constraints: [
            equal(\.topAnchor, toView: headerView, withAnchor: \.bottomAnchor, constant: 6),
            equal(\.leadingAnchor, toView: iconImageView, withAnchor: \.trailingAnchor, constant: 12),
            equal(\.trailingAnchor, constant: -12),
            equal(\.bottomAnchor, constant: -12)
        ])
    }
    
    override func updateUI() {
        super.updateUI()
        
        checkView.isOn = model.touple.status.isActive
        titleLabel.text = model.touple.descriptor.type.name
        iconImageView.image = model.touple.descriptor.type.icon
        checkView.isEnabled = true
        switchLabel.textColor = .black
        
        charTypeView.removeAllSubviews()
        
        func _addMLCUI() {
            charTypeView.addArrangedSubview(ucfLabel)
            charTypeView.addArrangedSubview(configButton)
            charTypeView.alignment = .center
            
            if !model.touple.status.ucfLoaded {
                checkView.isEnabled = false
                switchLabel.textColor = .lightGray
                
                configButton.setTitle("sensor.data.load.ucf".localizedFromGUI.uppercased(), for: .normal)
                ucfLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.7)
                ucfLabel.setTitleColor(currentTheme.color.secondary, for: .normal)
                ucfLabel.setTitle("sensor.data.no.ucf".localizedFromGUI, for: .normal)
                ucfLabel.setImage(UIImage.namedFromGUI("icon_cross"), for: .normal)
                ucfLabel.tintColor = currentTheme.color.secondary
            } else {
                configButton.setTitle("sensor.data.change.ucf".localizedFromGUI.uppercased(), for: .normal)
                ucfLabel.backgroundColor = currentTheme.color.secondary.withAlphaComponent(0.7)
                ucfLabel.setTitleColor(.white, for: .normal)
                ucfLabel.setTitle("sensor.data.ok.ucf".localizedFromGUI, for: .normal)
                ucfLabel.setImage(UIImage.namedFromGUI("icon_checkmark"), for: .normal)
                ucfLabel.tintColor = .white
            }
        }
        
        if model.touple.status.isActive {
            if model.touple.descriptor.type == .MLC {
                _addMLCUI()
            } else {
                model.sensor.optionsForSensor(model.touple).forEach { option in
                    let view = HSDCharTypeView()
                    view.model = option
                    view.onTap { [weak self] _ in
                        self?.charTypeOptionWantShowValues(option)
                    }
                    charTypeView.addArrangedSubview(view)
                }
            }
        } else {
            if model.touple.descriptor.type == .MLC {
                _addMLCUI()
            } else {
                let dummyView = UIView()
                dummyView.setDimensionContraints(width: nil, height: 34)
                charTypeView.addArrangedSubview(dummyView)
            }
        }
    }
    
    @objc
    private func loadConfiguration() {
        didTapLoadConfiguration(model.touple)
    }
    
    @objc
    private func switchDidChange(_ view: UISwitch) {
        switchDidChangeValue(model.touple, view.isOn)
    }
}
