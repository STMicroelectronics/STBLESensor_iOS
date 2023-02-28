//
//  SwitchView.swift
//
//  Created by Dimitri Giani on 13/01/21.
//  Copyright © 2021 STMicroelectronics. All rights reserved.
//

import UIKit
import BlueSTSDK

class SwitchView: BaseView {
    let checkView = UISwitch()
    let icon = UIImageView()
    let button = UIButton()
    
    var didSwitch: (Bool) -> () = { _ in }
    var didTapButton: () -> () = {}
    
    var model: HSDSensorTouple! {
        didSet {
            updateUI()
        }
    }
    
    override func configureView() {
        super.configureView()
        
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        
        icon.setDimensionContraints(width: 30, height: 30)
        let stack = UIStackView.getHorizontalStackView(withSpacing: 2, views: [icon, checkView])
        let hstack = UIStackView.getVerticalStackView(withSpacing: 2, views: [stack, button])
        checkView.addTarget(self, action: #selector(switchDidChange(_:)), for: .valueChanged)
        
        addSubviewAndFit(hstack)
        
        configureButton()
    }
    
    override func updateUI() {
        super.updateUI()
        
        configureButton()
        
        icon.image = model.descriptor.type.icon
        checkView.isOn = model.status.isActive
        checkView.onTintColor = currentTheme.color.secondary
        button.tintColor = currentTheme.color.secondary
        checkView.isEnabled = true
        
        let isMLC = model.descriptor.type == .MLC
        
        if isMLC {
            configureButton(visible: isMLC, title: isMLC ? "sensor.data.load.ucf".localizedFromGUI : nil)
            
            if !model.status.ucfLoaded {
                checkView.isEnabled = false
            }
        }
    }
    
    @objc
    private func switchDidChange(_ view: UISwitch) {
        didSwitch(view.isOn)
    }
    
    @objc
    private func buttonDidTap() {
        didTapButton()
    }
    
    func configureButton(visible: Bool = false, title: String? = nil) {
        button.isHidden = !visible
        button.setTitle(title, for: .normal)
    }
}
