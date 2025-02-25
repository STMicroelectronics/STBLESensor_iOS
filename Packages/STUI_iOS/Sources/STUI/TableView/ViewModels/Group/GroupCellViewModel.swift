//
//  GroupCellViewModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public typealias ChildViewModels = [any ViewViewModel]

public class GroupCellViewModel<ChildViews>: BaseCellViewModel<Void, GroupTableViewCell> where ChildViews == ChildViewModels {

    public var childViewModels: ChildViews
    var layout: Layout? = nil
    var tapGesture: UITapGestureRecognizerWithClosure?
    var isOpen: Bool = false
    var isCard: Bool = false
    var isExpandEnabled: Bool = true
    var isChildrenIndented: Bool = false

    public init(childViewModels: ChildViewModels, layout: Layout? = nil, isOpen: Bool = false, isCard: Bool = true, isExpandEnabled: Bool = true, isChildrenIndented: Bool = false) {
        self.childViewModels = childViewModels
        self.layout = layout
        self.isOpen = isOpen
        self.isCard = isCard
        self.isExpandEnabled = isExpandEnabled
        self.isChildrenIndented = isChildrenIndented
        super.init(param: Void())
    }

    public func add(viewModel: any ViewViewModel) {
        childViewModels.append(viewModel)
    }

    required public init() {
        self.childViewModels = []
        super.init()
    }

    public override func configure(view: GroupTableViewCell) {
        view.isCard = isCard

        if let layout = layout {
            view.contentView.backgroundColor = layout.backgroundColor?.light
        } else {
            view.update(.card)
        }

        if let margin = layout?.margin {
            view.update(margin)
        }

        view.stackView.arrangedSubviews.forEach { currentView in
            view.stackView.removeArrangedSubview(currentView)
            currentView.removeFromSuperview()
        }


        let childrenStackView = UIStackView()

        childrenStackView.spacing = 2.0
        childrenStackView.axis = .vertical

        for (index, currentViewModel) in childViewModels.enumerated() {

            guard (currentViewModel as? ImageDetailViewModel != nil) || (currentViewModel as? SimpleImageDetailViewModel != nil) else {
                continue;
            }

            let currentView = currentViewModel.make()
            view.stackView.addArrangedSubview(currentView)

            currentViewModel.configure(view: currentView)

            currentView.isHidden = false
        }

        let horizzontalStackView = UIStackView.getHorizontalStackView(withSpacing: 0.0,
                                                                      views: [
                                                                        UIView.empty(width: isChildrenIndented ? 30.0 : 0.0),
                                                                        childrenStackView,
                                                                        UIView.empty(width: isChildrenIndented ? 5.0 : 0.0)
                                                                      ])

        horizzontalStackView.isHidden = !self.isOpen
        view.stackView.addArrangedSubview(horizzontalStackView)

        for (index, currentViewModel) in childViewModels.enumerated() {

            guard (currentViewModel as? ImageDetailViewModel == nil) && (currentViewModel as? SimpleImageDetailViewModel == nil) else {
                continue;
            }

            let currentView = currentViewModel.make()
            childrenStackView.addArrangedSubview(currentView)

            currentViewModel.configure(view: currentView)

            currentView.isHidden = false
        }

        for (index, currentView) in view.stackView.arrangedSubviews.enumerated() {
            if index == 0, let headerView = currentView as? ImageDetailView {
                headerView.isHidden = false
                headerView.childView?.alpha = self.isOpen ? 0.0 : 1.0
                headerView.childView?.isUserInteractionEnabled = !self.isOpen
            } else {
                currentView.isHidden = !self.isOpen
            }
        }

        self.tapGesture = UITapGestureRecognizerWithClosure(closure: {  [weak self] tap in
            guard let self = self else { return }
            if !self.isExpandEnabled {
                return
            }
            self.isOpen = !self.isOpen
            
            UIView.animate(withDuration: 0.3) {
                for (index, currentView) in view.stackView.arrangedSubviews.enumerated() {
                    if index == 0, let headerView = currentView as? ImageDetailView {
                        headerView.isHidden = false
                        headerView.childView?.alpha = self.isOpen ? 0.0 : 1.0
                        headerView.childView?.isUserInteractionEnabled = !self.isOpen
                    } else {
                        currentView.isHidden = !self.isOpen
                    }
                }
            }
            
            view.tableView?.beginUpdates()
            view.tableView?.endUpdates()
        })

        if let firstView = view.stackView.arrangedSubviews.first {

            guard let tapGesture = tapGesture else { return }

            firstView.gestureRecognizers?.forEach({ gesture in
                firstView.removeGestureRecognizer(gesture)
            })

            firstView.addGestureRecognizer(tapGesture)
        }
    }

    public override func update(view: GroupTableViewCell, values: [any KeyValue]) {

        let views = view.stackView.arrangedSubviews
        guard let childrenContainerStackView = view.stackView.arrangedSubviews.last as? UIStackView,
              let childrenStackView = childrenContainerStackView.arrangedSubviews[1] as? UIStackView else {
            return
        }

        for (index, view) in views.enumerated() {
            if index == 0 {
                let viewModel = childViewModels[index]
                viewModel.update(view: view, values: values)
            }
        }

        for (index, view) in childrenStackView.arrangedSubviews.enumerated() {
            if childViewModels.count > index + 1 {
                let viewModel = childViewModels[index + 1]
                viewModel.update(view: view, values: values)
            }
        }
    }

    public override func update(with values: [any KeyValue]) {
        for viewModel in childViewModels {
            viewModel.update(with: values)
        }
    }

    @objc
    func handleTap(_ sender: UITapGestureRecognizer) {
        isOpen = !isOpen
    }
}
