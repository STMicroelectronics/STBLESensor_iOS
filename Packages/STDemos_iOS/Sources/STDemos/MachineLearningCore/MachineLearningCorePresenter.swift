//
//  MachineLearningCorePresenter.swift
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

public final class MachineLearningCorePresenter: DemoBasePresenter<MachineLearningCoreViewController, String> {

    var firstMLCSampleDelegate: MachineLearningFirstSampleDelegate?
    public typealias FirstMLCSampleCompletion = (_ sample: MachineLearningCoreData?) -> Void
    
    var director: TableDirector?
    
    private var valueConsole:ValueLabelConsole?
    
    var onNewStatusAvailable:(([RegisterStatus])->())? = nil
    private var lastStatus:[RegisterStatus]? {
        didSet{
            if let notifyStatus = self.lastStatus,
                let callback = self.onNewStatusAvailable{
                DispatchQueue.main.async {
                    callback(notifyStatus)
                }
            }
        }
    }
    
    private var mapper:ValueLabelMapper? {
        didSet{
            self.lastStatus = self.lastStatus?.map{ oldRegister in
                let regId = oldRegister.registerId
                let value = oldRegister.value
                return RegisterStatus(registerId: regId, value: value,
                               algorithmName: mapper?.algorithmName(register: regId),
                               label: mapper?.valueName(register: regId, value: value))
            }
        }
    }
}

// MARK: - MachineLearningCoreViewControllerDelegate
extension MachineLearningCorePresenter: MachineLearningCoreDelegate {

    public func load() {
        
        demo = .machineLearningCore
        
        demoFeatures = param.node.characteristics.features(with: Demo.machineLearningCore.features)
        
        if director == nil {
            
            director = TableDirector(with: view.tableView)
            
            director?.register(
                viewModel: RegisterAiViewModel.self,
                type: .fromClass,
                bundle: .module
            )
            
        }
        
        view.configureView()
    }
    
    public func updateMlcDemo(with feature: STBlueSDK.MachineLearningCoreFeature) {
        if let sample = feature.sample,
           let data = sample.data {
            
            let numRegisters = 0..<data.registerStatus.count
            
            for num in numRegisters {
                if let rawValue = data.registerStatus[num].value {
                    let algoName = mapper?.algorithmName(register: ValueLabelMapper.RegisterIndex(num)) ?? nil
                    let valueName = mapper?.valueName(register: ValueLabelMapper.RegisterIndex(num), value: rawValue) ?? nil
                    let registerAiData = RegisterAiData(
                        title: "Decision Tree: \(num)",
                        algorithm: algoName,
                        labelledValue: valueName,
                        rawValue: "\(rawValue)"
                    )
                    if let director = director {
                        if !(director.elements.isEmpty){
                            director.elements[num] = RegisterAiViewModel(param: registerAiData)
                        }
                    }
                }
            }
            self.director?.reloadData()
        }
    }
    
    public func retrieveLabelData() {
        if let ucfHeaderStringLabels = param.param {
            self.valueConsole = ValueLabelConsole()
            self.mapper = self.valueConsole?.buildRegisterMapperFromString(ucfHeaderStringLabels)
            self.readInitialSample { mlcFirstSample in
                self.initializeUI(withSampleData: mlcFirstSample)
            }
        } else {
            BlueManager.shared.sendMessage(
                "getMLCLabels\n",
                to: param.node,
                completion:  DebugConsoleCallback(
                    timeOut: 2.0,
                    onCommandResponds: { text in
                        self.valueConsole = ValueLabelConsole()
                        self.mapper = self.valueConsole?.buildRegisterMapperFromString(text)
                        self.readInitialSample { mlcFirstSample in
                            self.initializeUI(withSampleData: mlcFirstSample)
                        }
                    }, onCommandError: {
                        print("ERROR")
                    }
                )
            )
        }
    }
    
    private func readInitialSample(_ completion: @escaping FirstMLCSampleCompletion) {
        if let mlcFeature = param.node.characteristics.first(with: MachineLearningCoreFeature.self) {
            firstMLCSampleDelegate = MachineLearningFirstSampleDelegate(completion: completion)
            
            guard let firstMLCSampleDelegate = firstMLCSampleDelegate else { return }
            
            BlueManager.shared.read(feature: mlcFeature, for: param.node, delegate: firstMLCSampleDelegate)
        }
        
    }
    
    private func initializeUI(withSampleData data: MachineLearningCoreData?) {
        if let data = data {
            let numRegisters = 0..<data.registerStatus.count
            
            for num in numRegisters {
                let registerAiData = RegisterAiData(
                    title: "Decision Tree: \(num)",
                    algorithm: mapper?.algorithmName(register: ValueLabelMapper.RegisterIndex(num)) ?? nil,
                    labelledValue: nil,
                    rawValue: "0x0"
                )
                director?.elements.append(RegisterAiViewModel(param: registerAiData))
            }
            
            director?.reloadData()
        }
    }
}
