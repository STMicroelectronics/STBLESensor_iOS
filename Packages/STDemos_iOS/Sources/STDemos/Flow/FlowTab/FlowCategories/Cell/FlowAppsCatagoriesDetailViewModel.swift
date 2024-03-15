//
//  FlowAppsCatagoriesDetailViewModel.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STUI
import STBlueSDK

public class FlowAppsCatagoriesDetailViewModel: BaseCellViewModel<Flow, FlowAppsCategoriesCell> {

    let onFlowAppCategoryDetailClicked: ((_ param: Flow) -> Void)
    let onFlowUploadClicked: ((_ param: Flow) -> Void)
    let onFlowDeleteClicked: ((_ param: Flow) -> Void)
    let isDeleteButtonVisible: Bool

    public init(
        param: Flow,
        onFlowAppCategoryDetailClicked: @escaping ((_ param: Flow) -> Void),
        onFlowUploadClicked: @escaping ((_ param: Flow) -> Void),
        onFlowDeleteClicked: @escaping ((_ param: Flow) -> Void),
        isDeleteButtonVisible: Bool = false
    ) {
        self.onFlowAppCategoryDetailClicked = onFlowAppCategoryDetailClicked
        self.onFlowUploadClicked = onFlowUploadClicked
        self.onFlowDeleteClicked = onFlowDeleteClicked
        self.isDeleteButtonVisible = isDeleteButtonVisible
        
        super.init(param: param)
    }

    required init() {
        fatalError("init() has not been implemented")
    }

    public override func configure(view: FlowAppsCategoriesCell) {
        TextLayout.title2.size(16.0).apply(to: view.flowAppCategoryName)

        guard let param = param else { return }

        view.flowAppCategoryName.text = param.name

        view.flowAppCategoryIcon.contentMode = .scaleAspectFill
        view.flowAppCategoryIcon.image = ImageLayout.image(with: param.itemIcon, in: .module)?.maskWithColor(color: ColorLayout.primary.light)

        view.flowAppCategoryDisclosureIcon.contentMode = .scaleAspectFill
        view.flowAppCategoryDisclosureIcon.image = ImageLayout.image(with: "flow_upload", in: .module)?.maskWithColor(color: ColorLayout.primary.light)
        view.flowAppCategoryDisclosureIcon.setDimensionContraints(width: 20, height: 20)
        
        let uploadTap = UITapGestureRecognizer(target: self, action: #selector(flowUploadItemTapped(_:)))
        view.flowAppCategoryDisclosureIcon.isUserInteractionEnabled = true
        view.flowAppCategoryDisclosureIcon.addGestureRecognizer(uploadTap)
        
        if isDeleteButtonVisible {
            view.flowAppCategoryDeleteIcon.contentMode = .scaleAspectFill
            view.flowAppCategoryDeleteIcon.image = ImageLayout.Common.delete?.maskWithColor(color: ColorLayout.red.auto)
            view.flowAppCategoryDeleteIcon.setDimensionContraints(width: 20, height: 20)
            view.flowAppCategoryDeleteSV.isHidden = !isDeleteButtonVisible
            
            let deleteTap = UITapGestureRecognizer(target: self, action: #selector(flowDeleteItemTapped(_:)))
            view.flowAppCategoryDeleteIcon.isUserInteractionEnabled = true
            view.flowAppCategoryDeleteIcon.addGestureRecognizer(deleteTap)
        }
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(flowAppCategoryDetailItemTapped(_:)))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(viewTap)
    }
}

extension FlowAppsCatagoriesDetailViewModel {
    @objc
    func flowAppCategoryDetailItemTapped(_ sender: UITapGestureRecognizer) {
        if let param = param {
            onFlowAppCategoryDetailClicked(param)
        }
    }
    
    @objc
    func flowUploadItemTapped(_ sender: UITapGestureRecognizer) {
        if let param = param {
            onFlowUploadClicked(param)
        }
    }
    
    @objc
    func flowDeleteItemTapped(_ sender: UITapGestureRecognizer) {
        if let param = param {
            onFlowDeleteClicked(param)
        }
    }
}
