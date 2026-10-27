//
//  EmptyViewModel.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class EmptyViewModel: BaseViewModel<CodeValue<Void>, VoidView> {

    public override func configure(view: VoidView) {
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }

    public override func update(view: VoidView, values: [any KeyValue]) {
    }
}
