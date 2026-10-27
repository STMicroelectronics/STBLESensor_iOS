//
//  UCFStatusViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class UCFStatusViewModel: BaseViewModel<CodeValue<String>, UCFStatusView> {

    public override func configure(view: UCFStatusView) {

        view.textLabel.text = param?.value

        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)

        if let layout = layout {
            layout.textLayout?.apply(to: view.textLabel)
        }
    }

    public override func update(view: UCFStatusView,
                                values: [any KeyValue]) {

        guard let update = values.first(where: {
            $0.keys == param?.keys
        }) else { return }

        if let isLoaded = update.value as? Bool {

            let statusText = isLoaded
                ? "File Loaded"
                : "File Not Loaded"

            param?.value = statusText

            view.textLabel.text = statusText

            view.textLabel.textColor = isLoaded
                ? .systemGreen
                : .systemRed
        }
    }
}
