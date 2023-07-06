//
//  GenericViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public protocol ViewModel {

    associatedtype View: UIView

    static var reusableIdentifier: String { get }

    init()

    func configure(view: View)

    func update(view: View, values: [any KeyValue])

    func update(with values: [any KeyValue])
}
