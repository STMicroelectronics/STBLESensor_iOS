//
//  HSDTagCell.swift
//  W2STApp
//
//  Created by Dimitri Giani on 01/02/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK_Gui

class HSDTagCell: BaseTableViewCell {
    private let typeLabel = UILabel()
    private let nameLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let editButton = UIButton()
    private let enabledView = UISwitch()
    
    var didChangeEnabled: (Bool, HSDTag) -> Void = { _, _ in }
    var didWantEdit: (HSDTag) -> Void = { _ in }
    
    var hsdTag: HSDTag! {
        didSet {
            updateUI()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cellActionButtonLabel?.textColor = .white
    }
    
    override func configureView() {
        super.configureView()
        
        nameLabel.textColor = .gray
        descriptionLabel.textColor = .gray
        typeLabel.textColor = .gray
        typeLabel.font = UIFont.systemFont(ofSize: 12)
        nameLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.font = UIFont.systemFont(ofSize: 12)
        
        editButton.setImage(UIImage(), for: .normal)
        editButton.tintColor = currentTheme.color.secondary
        enabledView.onTintColor = currentTheme.color.secondary
        
        editButton.addTarget(self, action: #selector(editDidTap), for: .touchUpInside)
        enabledView.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)
        
        editButton.setDimensionContraints(width: 36, height: nil)
        
        let hStack = UIStackView.getHorizontalStackView(withSpacing: 4, views: [editButton, nameLabel, descriptionLabel, enabledView])
        let vStack = UIStackView.getVerticalStackView(withSpacing: 8, views: [typeLabel, hStack])
        
        containerView.addSubviewAndFit(vStack, top: 16, trailing: 16, bottom: 16, leading: 16)
    }
    
    override func updateUI() {
        super.updateUI()
        
        nameLabel.text = hsdTag.label
        descriptionLabel.text = hsdTag.pinDesc
        typeLabel.text = hsdTag.type?.title.localizedFromGUI
    }
    
    @objc
    private func switchDidChange(_ view: UISwitch) {
        didChangeEnabled(view.isOn, hsdTag)
    }
    
    @objc
    private func editDidTap() {
        didWantEdit(hsdTag)
    }
    
    func setEnabled(_ enabled: Bool) {
        enabledView.isOn = enabled
    }
    
    func setIsLogging(_ isLogging: Bool) {
        editButton.setImage(UIImage.namedFromGUI(isLogging ? "ic_edit_off" : "ic_edit_on"), for: .normal)
        editButton.isHidden = isLogging
        enabledView.isHidden = hsdTag.type == .hardware && isLogging
    }
}
