//
//  FiniteStateMachinePresenter.swift
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

final class FiniteStateMachinePresenter: DemoPresenter<FiniteStateMachineViewController> {
    
    var firstFSMSampleDelegate: FinitStateMachineFirstSampleDelegate?
    public typealias FirstFSMSampleCompletion = (_ sample: FiniteStateMachineData?) -> Void
    
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

// MARK: - FiniteStateMachineViewControllerDelegate
extension FiniteStateMachinePresenter: FiniteStateMachineDelegate {

    func load() {
        demo = .finiteStateMachine
        
        demoFeatures = param.node.characteristics.features(with: Demo.finiteStateMachine.features)
        
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
    
    func update(with feature: STBlueSDK.FiniteStateMachineFeature) {
        if let sample = feature.sample,
           let data = sample.data {
            
            let numRegisters = 0..<data.registerStatus.count
            
            for num in numRegisters {
                if let algoName = mapper?.algorithmName(register: ValueLabelMapper.RegisterIndex(num)){
                    if let rawValue = data.registerStatus[num].value {
                        if let valueName = mapper?.valueName(register: ValueLabelMapper.RegisterIndex(num), value: rawValue) {
                            let registerAiData = RegisterAiData(
                                title: "Program: \(num)",
                                algorithm: algoName,
                                labelledValue: valueName,
                                rawValue: "\(rawValue)"
                            )
                            director?.elements[num] = RegisterAiViewModel(param: registerAiData)
                        }
                    }
                }
            }
            self.director?.reloadData()
        }
    }
    
    func retrieveLabelData() {
        BlueManager.shared.sendMessage(
            "getFSMLabels\n",
            to: param.node,
            completion:  DebugConsoleCallback(
                timeOut: 2.0,
                onCommandResponds: { text in
                    self.valueConsole = ValueLabelConsole()
                    self.mapper = self.valueConsole?.buildRegisterMapperFromString(text)
                    self.readInitialSample { fsmFirstSample in
                        self.initializeUI(withSampleData: fsmFirstSample)
                    }
                }, onCommandError: {
                    print("ERROR")
                }
            )
        )
    }
    
    private func readInitialSample(_ completion: @escaping FirstFSMSampleCompletion) {
        if let fsmFeature = param.node.characteristics.first(with: FiniteStateMachineFeature.self) {
            firstFSMSampleDelegate = FinitStateMachineFirstSampleDelegate(completion: completion)
            
            guard let firstFSMSampleDelegate = firstFSMSampleDelegate else { return }
            
            BlueManager.shared.read(feature: fsmFeature, for: param.node, delegate: firstFSMSampleDelegate)
        }
        
    }
    
    private func initializeUI(withSampleData data: FiniteStateMachineData?) {
        if let data = data {
            
            let numRegisters = 0..<data.registerStatus.count
            
            for num in numRegisters {
                let registerAiData = RegisterAiData(
                    title: "Program: \(num)",
                    algorithm: mapper?.algorithmName(register: ValueLabelMapper.RegisterIndex(num)) ?? "---",
                    labelledValue: "",
                    rawValue: "0"
                )
                director?.elements.append(RegisterAiViewModel(param: registerAiData))
            }
            director?.reloadData()
        }
    }

}
