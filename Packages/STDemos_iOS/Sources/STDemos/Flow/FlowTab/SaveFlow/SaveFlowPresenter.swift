//
//  SaveFlowPresenter.swift
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

final class SaveFlowPresenter: BasePresenter<SaveFlowViewController, FlowAndNodeParam> {

    var currentName: String = ""
    
}

// MARK: - SaveFlowViewControllerDelegate
extension SaveFlowPresenter: SaveFlowDelegate {

    func load() {
        view.configureView()
        
        view.nameTextField.text = param.flow.name
        view.descriptionTextField.text = param.flow.notes
        
        currentName = param.flow.name
    }
    
    func doneButtonTapped() {
        guard let name = view.nameTextField.text, !name.sanitazed().isEmpty else {
            ModalService.showWarningMessage(with: "To save, you need to provide a name to the App")
            return
        }
        
        param.flow.name = name
        param.flow.notes = view.descriptionTextField.text ?? ""
        
        if currentName != flowDefaultName, currentName != view.nameTextField.text {
            param.flow.identifier = UUID().uuidString
        }
        
        if PersistanceService.shared.exists(flow: param.flow) {
            ModalService.showConfirm(with: "Error an App with this name already exist. Overwrite it?") { [weak self] success in
                if success {
                    guard let self = self else { return }
                    PersistanceService.shared.save(flow: param.flow)
//                    self.view.navigationController?.popToControllerOrToRootControllerIfNotInTheStack(TabBarViewController.self, animated: true)
                    self.view.navigationController?.popToExpertViewController(FlowExpertViewController.self, animated: true, param: self.param.node)
                }
            }
        } else {
            PersistanceService.shared.save(flow: param.flow)
//            self.view.navigationController?.popToControllerOrToRootControllerIfNotInTheStack(TabBarViewController.self, animated: true)
            self.view.navigationController?.popToExpertViewController(FlowExpertViewController.self, animated: true, param: self.param.node)
        }
    }
    
    func cancelButtonTapped() {
        self.view.navigationController?.popViewController(animated: true)
    }

}

extension UINavigationController {
    func popToController<T: UIViewController>(_ type: T.Type, animated: Bool) {
        if let controller = viewControllers.first(where: { $0 is T }) {
            popToViewController(controller, animated: animated)
        }
    }
    
    func popToControllerOrToRootControllerIfNotInTheStack<T: UIViewController>(_ type: T.Type, animated: Bool) {
        if let controller = viewControllers.first(where: { $0 is T }) {
            popToViewController(controller, animated: animated)
        } else {
            popToRootViewController(animated: animated)
        }
    }
    
    func popToExpertViewController<T: UIViewController>(_ type: T.Type, animated: Bool, param: Node) {
        if let controller = viewControllers.first(where: { $0 is T }) {
            popToViewController(controller, animated: animated)
        } else {
            pushViewController(FlowExpertPresenter(param: param).start(), animated: true)
        }
    }
    
}
