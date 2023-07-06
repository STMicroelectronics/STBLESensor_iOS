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

final class DemoGroupFilterPresenter: BasePresenter<DemoGroupFilterViewController, [DemoGroup]> {
    var tempFilter: [DemoGroup] = [DemoGroup]()
    var completion: (([DemoGroup]) -> Void)?

    convenience init(param: [DemoGroup], completion: (([DemoGroup]) -> Void)?) {
        self.init(param: param)
        self.completion = completion
    }
}

// MARK: - DemoGroupFilterDelegate
extension DemoGroupFilterPresenter: DemoGroupFilterDelegate {

    func load() {
        view.configureView()

        tempFilter.append(contentsOf: param)

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

    }

    func cancel() {
        self.view.dismiss(animated: true)
    }

    func done() {
        guard let completion = completion else { return }
        completion(tempFilter)
        
        self.view.dismiss(animated: true)
    }

}
