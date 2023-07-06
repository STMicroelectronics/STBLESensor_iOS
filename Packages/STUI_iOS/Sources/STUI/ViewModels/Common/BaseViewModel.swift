//
//  BaseViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public struct Layout {
    public var mainColor: Colorable?
    public var backgroundColor: Colorable?
    public var textLayout: TextLayout?
    public var titleLayout: TextLayout?
    public var buttonLayout: Buttonlayout?
    public var margin: Margin?


    public init(mainColor: Colorable? = nil,
                backgroundColor: Colorable? = nil,
                textLayout: TextLayout? = nil,
                titleLayout: TextLayout? = nil,
                buttonLayout: Buttonlayout? = nil,
                margin: Margin? = nil) {
        self.mainColor = mainColor
        self.backgroundColor = backgroundColor
        self.textLayout = textLayout
        self.titleLayout = titleLayout
        self.buttonLayout = buttonLayout
        self.margin = margin
    }
}

open class BaseViewModel<Param, View: UIView>: ViewViewModel {

    public var param: Param?
    public var layout: Layout?

    public var onUpdate: ((String) -> Void)?

    required public init() {
        self.param = nil
    }

    public init(param: Param?, layout: Layout? = nil) {
        self.param = param
        self.layout = layout
    }

    open func configure(view: View) {

    }

    open func update(view: View, values: [any KeyValue]) {

    }

    open func update(with values: [any KeyValue]) {
        
    }
}
