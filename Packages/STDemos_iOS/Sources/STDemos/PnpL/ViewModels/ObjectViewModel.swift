//
//  ObjectViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI

public class ObjectViewModel: BaseViewModel<String, ObjectView> {

    var childrenViewModels: [any ViewViewModel]

    init(param: String?, layout: Layout? = nil, childrenViewModels: [any ViewViewModel]) {
        self.childrenViewModels = childrenViewModels

        super.init(param: param, layout: layout)
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
    
    public override func configure(view: ObjectView) {

        if let layout = layout {
            layout.textLayout?.apply(to: view.objectLabel)
        }

        view.objectLabel.text = self.param
        view.childrenStackView.arrangedSubviews.forEach { currentView in
            view.childrenStackView.removeArrangedSubview(currentView)
            currentView.removeFromSuperview()
        }

        for (_, currentViewModel) in childrenViewModels.enumerated() {

            let currentView = currentViewModel.make()
            view.childrenStackView.addArrangedSubview(currentView)

            currentViewModel.configure(view: currentView)
        }
    }

    public override func update(view: ObjectView, values: [any KeyValue]) {

        let views = view.childrenStackView.arrangedSubviews
        for (index, view) in views.enumerated() {
            let viewModel = childrenViewModels[index]
            viewModel.update(view: view, values: values)
        }
    }

    public override func update(with values: [any KeyValue]) {
        for viewModel in childrenViewModels {
            viewModel.update(with: values)
        }
    }
}
