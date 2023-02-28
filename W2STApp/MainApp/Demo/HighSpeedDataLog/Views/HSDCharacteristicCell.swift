//
//  HSDCharacteristicCell.swift
//
//  Created by Dimitri Giani on 13/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import STTheme

class HSDCharacteristicCell: BaseTableViewCell {
    enum Mode {
        case compact
        case full
    }
    
    private var headerView: UIStackView!
    private let numberLabel = UILabel()
    private let codeLabel = UILabel()
    private let iconImageView = UIImageView()
    private let compactView = UIStackView()
    private let fullView = UIStackView()
    private var model: HSDSensor!
    
    var mode = Mode.compact {
        didSet {
            updateUI()
        }
    }
    
    var didTapHeader: ()->() = {}
    var switchDidChangeValue: (HSDSensorTouple, Bool) -> () = { _, _ in }
    var charTypeOptionWantShowValues: (HSDOptionModel, HSDSensorTouple) -> () = { _, _ in }
    var didTapLoadConfiguration: (HSDSensorTouple) -> () = { _ in }
    
    override func configureView() {
        super.configureView()
        
        selectionStyle = .none
        compactView.alignment = .leading
        compactView.spacing = 6
        fullView.spacing = 6
        fullView.axis = .vertical
        
        numberLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        codeLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        numberLabel.textColor = ThemeService.shared.currentTheme.color.primary
        numberLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        codeLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        let iconContainer = UIView()
        iconContainer.addSubviewAndCenter(iconImageView)
        
        headerView = UIStackView.getHorizontalStackView(withSpacing: 2, views: [numberLabel, codeLabel, iconContainer])
        headerView.setDimensionContraints(width: nil, height: 30)
        iconContainer.setDimensionContraints(width: 14, height: nil)
        iconImageView.setDimensionContraints(width: 14, height: 14)
        
        containerView.topConstraint?.constant = 12
        containerView.bottomConstraint?.constant = 12
        containerView.leadingConstraint?.constant = 12
        containerView.trailingConstraint?.constant = 12
        
        containerView.applyShadowedStyle()
        
        containerView.addSubview(headerView, constraints: [
            equal(\.topAnchor, constant: 8),
            equal(\.leadingAnchor, constant: 12),
            equal(\.trailingAnchor, constant: -12)
        ])
        
        headerView.onTap { [weak self] _ in
            self?.didTapHeader()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetViews()
    }
    
    override func updateUI() {
        super.updateUI()
        
        codeLabel.text = model.name
        
        switch mode {
            case .compact:
                setupCompactMode()
                iconImageView.image = UIImage.namedFromGUI("icon_arrow_down")
                
            case .full:
                setupFullMode()
                iconImageView.image = UIImage.namedFromGUI("icon_arrow_up")
        }
    }
    
    func setModel(_ model: HSDSensor, isExpanded: Bool, tapAction: @escaping ()->()) {
        self.model = model
        didTapHeader = tapAction
        numberLabel.text = String(model.id)
        mode = isExpanded ? .full : .compact
    }
    
    private func resetViews() {
        compactView.removeAllSubviews()
        compactView.removeFromSuperview()
        fullView.removeAllSubviews()
        fullView.removeFromSuperview()
    }
    
    private func setupCompactMode() {
        resetViews()

        model.subSensors.forEach { subSensor in
            let view = SwitchView()
            view.model = subSensor
            view.didSwitch = { [weak self] isOn in
                self?.switchDidChangeValue(subSensor, isOn)
            }
            view.didTapButton = { [weak self] in
                self?.didTapLoadConfiguration(subSensor)
            }
            compactView.addArrangedSubview(view)
        }
        
        containerView.addSubview(compactView, constraints: [
            equal(\.topAnchor, toView: headerView, withAnchor: \.bottomAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 12),
            equal(\.bottomAnchor, constant: -12)
        ])
        
        containerView.trailingAnchor.constraint(greaterThanOrEqualTo: containerView.trailingAnchor, constant: -12).isActive = true
    }
    
    private func setupFullMode() {
        resetViews()
        
        model.subSensors.forEach { subSensor in
            let view = HSDCharacteristicDetailView()
            view.model = (model, subSensor)
            view.switchDidChangeValue = { [weak self] subSensor, isOn in
                self?.switchDidChangeValue(subSensor, isOn)
            }
            view.charTypeOptionWantShowValues = { [weak self] option in
                self?.charTypeOptionWantShowValues(option, subSensor)
            }
            view.didTapLoadConfiguration = { [weak self] model in
                self?.didTapLoadConfiguration(model)
            }
            fullView.addArrangedSubview(view)
        }
        
        containerView.addSubview(fullView, constraints: [
            equal(\.topAnchor, toView: headerView, withAnchor: \.bottomAnchor, constant: 16),
            equal(\.leadingAnchor, constant: 12),
            equal(\.trailingAnchor, constant: -12),
            equal(\.bottomAnchor, constant: -12)
        ])
    }
}
