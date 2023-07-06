//
//  ViewViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public protocol ViewViewModel: ViewModel {

}

public extension ViewViewModel {
    
    static var reusableIdentifier: String {
        return String(describing: View.self)
    }

    func configure(view: UIView) {
        guard let view = view as? View else { return }
        configure(view: view)
    }

    func update(view: UIView, values: [any KeyValue]) {
        guard let view = view as? View else { return }
        update(view: view, values: values)
    }

    func make() -> View {
        View(frame: .zero)
    }
}
