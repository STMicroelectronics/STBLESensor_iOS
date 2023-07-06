//
//  SwitchViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class SwitchInput {
    public var title: String?
    public var value: Bool?
    public var isEnabled: Bool
    public var handleValueChanged: (CodeValue<SwitchInput>) -> Void

    public init(title: String? = nil,
                value: Bool = false,
                isEnabled: Bool = true,
                handleValueChanged: @escaping (CodeValue<SwitchInput>) -> Void) {
        self.title = title
        self.value = value
        self.isEnabled = isEnabled
        self.handleValueChanged = handleValueChanged
    }
}

public class SwitchViewModel: BaseViewModel<CodeValue<SwitchInput>, SwitchView> {

    public override func configure(view: SwitchView) {

        if let layout = layout {
            layout.textLayout?.apply(to: view.titleLabel)
            view.enableSwitch.onTintColor = layout.mainColor?.auto
        }

        view.titleLabel.text = param?.value.title
        view.titleLabel.isHidden = param?.value.title == nil
        view.emptyView.isHidden = param?.value.title == nil
        
        view.enableSwitch.isOn = param?.value.value ?? false
        view.enableSwitch.isEnabled = param?.value.isEnabled ?? false

        view.enableSwitch.addTarget(self, action: #selector(enableSwitchValueChanged(_:)), for: .valueChanged)
    }

    public override func update(view: SwitchView, values: [any KeyValue]) {
        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) }) else { return }

        param?.value.value = (value.value as? Bool) ?? false
        view.titleLabel.text = param?.value.title
        view.enableSwitch.isOn = param?.value.value ?? false
    }

    public override func update(with values: [any KeyValue]) {
        guard let value = values.first(where: { $0.keys.joined(separator: "|".lowercased()) == param?.keys.joined(separator: "|".lowercased()) }) else { return }

        param?.value.value = (value.value as? Bool) ?? false
    }

    @objc
    func enableSwitchValueChanged(_ sender: UISwitch) {

        param?.value.value = sender.isOn

        guard let param = param else { return }
        param.value.handleValueChanged(param)
    }
}
