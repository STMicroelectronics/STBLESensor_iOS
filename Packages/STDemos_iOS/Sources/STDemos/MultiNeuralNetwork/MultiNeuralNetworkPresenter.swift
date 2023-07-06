//
//  MultiNeuralNetworkPresenter.swift
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

struct AvailableAlgorithm : Equatable{
    let index:Int
    let name:String
    
    static func == (lhs: AvailableAlgorithm, rhs: AvailableAlgorithm) -> Bool {
        return lhs.index == rhs.index
    }
}

final class MultiNeuralNetworkPresenter: DemoPresenter<MultiNeuralNetworkViewController> {
    private static let TIME_FORMAT:DateFormatter = {
        var timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        return timeFormatter
    }()
}

// MARK: - MultiNeuralNetworkViewControllerDelegate
extension MultiNeuralNetworkPresenter: MultiNeuralNetworkDelegate {

    func load() {
        
        demo = .multiNN
        
        demoFeatures = param.node.characteristics.features(with: Demo.multiNN.features)
        
        view.configureView()
    }

    func updateMultiNNUI(with sample: STBlueSDK.AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<AudioClassificationData>,
           let data = sample.data {
            if let value = data.audioClass?.value {
                if(value == .off || value == .on){
                    view.audioClassificationView.state.text = value.description
                } else {
                    view.audioClassificationView.image.image = value.image
                    let time = MultiNeuralNetworkPresenter.TIME_FORMAT.string(from:Date())
                    view.audioClassificationView.descritpion.text = String(format:"%@: %@",time,value.description)
                }
            }
        } else if let sample = sample as? FeatureSample<ActivityData>,
           let data = sample.data {
            if let value = data.activity.value {
                view.humanActivityRecognitionView.image.image = value.image
                let time = MultiNeuralNetworkPresenter.TIME_FORMAT.string(from:Date())
                view.humanActivityRecognitionView.descritpion.text = String(format:"%@: %@",time,value.description)
            }
        }
    }
    
    func sendAlgotithmCommand(_ selectedAlgo: AvailableAlgorithm) {
        BlueManager.shared.sendMessage(
            "setAIAlgo \(selectedAlgo.index)",
            to: param.node,
            completion: DebugConsoleCallback(
                timeOut: 2.0,
                onCommandResponds: { text in
                    print("CHANGE ALGORITHM RESPONSE CALLBACK: \(text)")
                    self.view.currentAlgorithmView.currentAlgorithm.text = selectedAlgo.name
                }, onCommandError: {
                    UIAlertController.presentAlert(
                        from: self.view,
                        title: "ERROR",
                        message: "Response error from board",
                        actions: [
                            UIAlertAction.cancelButton { [weak self] _ in self?.view.dismiss(animated: true) }
                        ]
                    )
                }
            )
        )
    }
    
    func getAvailableAlgorithms() {
        BlueManager.shared.sendMessage(
            "getAllAIAlgo",
            to: param.node,
            completion:  DebugConsoleCallback(
                timeOut: 3.0,
                onCommandResponds: { response in
                    if let algos = self.extractAvailableAlgos(str: response){
                        self.view.availableAlgos = algos
                        self.getCurrentAlgorithm()
                    }
                }, onCommandError: {
                    UIAlertController.presentAlert(
                        from: self.view,
                        title: "ERROR",
                        message: "Impossibile to retrieve all supported algorithm.",
                        actions: [
                            UIAlertAction.cancelButton { [weak self] _ in self?.view.dismiss(animated: true) }
                        ]
                    )
                }
            )
        )
    }
    
    private func getCurrentAlgorithm() {
        BlueManager.shared.sendMessage(
            "getAIAlgo",
            to: param.node,
            completion:  DebugConsoleCallback(
                timeOut: 3.0,
                onCommandResponds: { response in
                    let splittedResponse = response.split(separator: "\r\n")
                    let indexResponse = String(splittedResponse[1])
                    if let index = Int(indexResponse) {
                        if let currentAlgo = self.findAlgoWithIndex(index) {
                            self.view.currentAlgo = currentAlgo
                        } else {
                            self.view.currentAlgo = self.view.availableAlgos[0]
                        }
                        self.view.containerCurrentAlgorithmView.isHidden = false
                        self.view.currentAlgorithmView.currentAlgorithm.text = self.view.currentAlgo?.name
                    }
                }, onCommandError: {
                    UIAlertController.presentAlert(
                        from: self.view,
                        title: "ERROR",
                        message: "Impossibile to retrieve running algorithm.",
                        actions: [
                            UIAlertAction.cancelButton { [weak self] _ in self?.view.dismiss(animated: true) }
                        ]
                    )
                }
            )
        )
    }
    
    private func findAlgoWithIndex(_ index:Int) -> AvailableAlgorithm?{
        return view.availableAlgos.first{ $0.index == index}
    }
    
    private func getAvailableAlgosResponse(from response:String) -> String?{
        if let matchRange = response.range(of: "((\\d+-.+,?)+)\\n", options: .regularExpression){
            let matchStr = response[matchRange].dropLast()
            return String(matchStr)
        }else{
            return nil
        }
    }
    
    private func extractAvailableAlgos(str:String)->[AvailableAlgorithm]?{
        return getAvailableAlgosResponse(from: str)?.split(separator: ",").compactMap{ algoStr in
            let algoDetails = algoStr.split(separator: "-")
            if algoDetails.count == 2,
                let id = Int(algoDetails[0]){
                return AvailableAlgorithm(index: id, name: String(algoDetails[1]))
            }else{
                return nil
            }
        }
    }
}
