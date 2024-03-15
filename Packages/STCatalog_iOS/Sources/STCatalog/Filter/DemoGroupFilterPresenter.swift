//
//  DemoGroupFilterPresenter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK
import STDemos
import TagListView

final class DemoGroupFilterPresenter: BasePresenter<DemoGroupFilterViewController, FilterParameters> {
    var tempFilter: [DemoGroup] = [DemoGroup]()
    var tempOrderFilter: OrderByGroup = OrderByGroup.none
    var completion: ((FilterParameters) -> Void)?

    convenience init(param: FilterParameters, completion: ((FilterParameters) -> Void)?) {
        self.init(param: param)
        self.completion = completion
    }
}

// MARK: - DemoGroupFilterDelegate
extension DemoGroupFilterPresenter: DemoGroupFilterDelegate {

    func load() {
        view.configureView()

        tempFilter.append(contentsOf: param.demosGroup)

        DemoGroup.allCases.forEach { [weak self] demoGroup in

            let tagView = self?.view.tagListView.addTag(demoGroup.rawValue)
            tagView?.isSelected = self?.tempFilter.contains(demoGroup) ?? false

            tagView?.onTap({ tagView in
                tagView.isSelected = !tagView.isSelected
                if tagView.isSelected {
                    self?.tempFilter.append(demoGroup)
                } else {
                    self?.tempFilter.removeAll(where: { $0 == demoGroup})
                }
            })
        }
        
        tempOrderFilter = param.orderingBy
        
        OrderByGroup.allCases.forEach { [weak self] orderGroup in
            
            let orderTagView = self?.view.orderListView.addTag(orderGroup.rawValue)
            
            if self?.tempOrderFilter.rawValue == orderGroup.rawValue {
                orderTagView?.isSelected = true
            } else {
                orderTagView?.isSelected = false
            }

            orderTagView?.onTap({ orderTagView in
                self?.resetOrderByFilter()
                orderTagView.isSelected = !orderTagView.isSelected
                if orderTagView.isSelected {
                    self?.tempOrderFilter = orderGroup
                } else {
                    self?.tempOrderFilter = .none
                }
            })
        }
    }
    
    func resetOrderByFilter() {
        self.view.orderListView.tagViews.forEach{ tv in
            tv.isSelected = false
        }
        self.tempOrderFilter = .none
    }

    func cancel() {
        self.view.dismiss(animated: true)
    }

    func done() {
        guard let completion = completion else { return }
        completion(FilterParameters(orderingBy: tempOrderFilter, demosGroup: tempFilter))
        
        self.view.dismiss(animated: true)
    }

}
