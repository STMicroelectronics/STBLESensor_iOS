//
//  FlowUploadPresenter.swift
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

final class FlowUploadPresenter: BasePresenter<FlowUploadViewController, FlowAndNodeParam> {
    var toUpload: Uploadable?
}

extension FlowUploadPresenter {
    func configure(with toUpload: Uploadable) {
        self.toUpload = toUpload
    }
}

// MARK: - FlowUploadViewControllerDelegate
extension FlowUploadPresenter: FlowUploadDelegate {

    func load() {
        view.configureView()
        
        TextLayout.title2.apply(to: view.flowNameLabel)
        TextLayout.info.apply(to: view.flowSizeLabel)
        
        view.flowNameLabel.text = param.flow.descr
        
        let dictionary: [String: Any] = param.flow.flatJsonDictionary()
        
        if let data = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
            print(String(data: data, encoding: .utf8) ?? "ERROR PARSING")
            view.flowSizeLabel.text = "Size Flow = \(data.count.byteSize)"
        }
        
        let error = [param.flow].isValid(param.node)
        
        switch error {
        case .none:
            break
        default:
            ModalService.showWarningMessage(with: error.localizedDescription)
            return
        }
    }
    
    func askForUploadCurrentFlow() {
        if let nodeName = param.node.name {
            print(nodeName)
        }
        
        ModalService.showAlert(
            with: "Overwrite board",
            message: "Any Apps currently loaded on board will be replaced. Do you want to continue?",
            okTitle: "Ok",
            cancelTitle: "Cancel"
        ) { [weak self] success in
            if success {
                guard let self = self else { return }
                self.uploadCurrentFlow(to: param.node)
            }
        }
    }
    
    func uploadCurrentFlow(to node: Node) {
        
        guard let toUpload = toUpload else {
            return
        }
        
        StandardHUD.shared.show(with: "Sending request.\n\n... Please wait ...")

        CommunicationService.shared.upload(toUpload: toUpload, to: node) { [weak self] error in
            guard let self = self else { return }
   
            switch error {
            case .trasmission(let trasmissionError):
                switch trasmissionError {
                case .none:
                    StandardHUD.shared.dismiss()
                    ModalService.showUploadMessage(with: error.localizedDescription){ [weak self] success in
                        guard let flows = toUpload as? Flows else{ return }
                        if flows.hasBLEOutput{
                            NotificationCenter.default.post(name: .didUploadFlowsWithStreamOnBleOutput, object: nil)
                        }
//                        if flows.hasSDOutput{
//                            ModalService.showMessage(with: "Connect to the board to start the data recording"){ _ in
//                                NotificationCenter.default.post(name: .didUploadFlowsWithStreamOnBleOutput, object: nil)
//                            }
//                        }
                        if success {
                            self?.view.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                    break
                default:
                    StandardHUD.shared.dismiss()
                    ModalService.showWarningMessage(with: error.localizedDescription)
                }
            default:
                StandardHUD.shared.dismiss()
                break
            }
        }
    }
}

extension Int {
    var byteSize: String {
        return ByteCountFormatter().string(fromByteCount: Int64(self))
    }
}

extension Notification.Name {
    static let didUploadFlowsWithStreamOnBleOutput = Notification.Name("didUploadFlowsWithStreamOnBleOutput")
}
