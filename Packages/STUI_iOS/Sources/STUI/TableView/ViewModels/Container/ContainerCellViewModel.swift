//
//  ContainerCellViewModel.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public class ContainerCellViewModel<ChildView>: BaseCellViewModel<Void, ContainerCell> where ChildView == any ViewViewModel {

    var childViewModel: ChildView
    var layout: Layout? = nil

    public init(childViewModel: ChildView, layout: Layout? = nil) {
        self.childViewModel = childViewModel
        self.layout = layout

        super.init(param: Void())
    }

    required public init() {
        self.childViewModel = LabelViewModel()
        super.init()
    }

    public override func configure(view: ContainerCell) {

        if let layout = layout {
            view.contentView.backgroundColor = layout.backgroundColor?.light
        }

        if let margin = layout?.margin {
            view.update(margin)
        }

        view.stackView.arrangedSubviews.forEach { currentView in
            view.stackView.removeArrangedSubview(currentView)
            currentView.removeFromSuperview()
        }

        let currentView = childViewModel.make()
        view.stackView.addArrangedSubview(currentView)
        childViewModel.configure(view: currentView)
    }

    public override func update(view: ContainerCell, values: [any KeyValue]) {

        guard let view = view.stackView.arrangedSubviews.first else { return }

        childViewModel.update(view: view, values: values)
    }

    public override func update(with values: [any KeyValue]) {
        childViewModel.update(with: values)
    }

}
