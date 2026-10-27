//
//  RegisterDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 21/10/2026.
//

import Foundation
import STBlueSDK

class RegisterDemoViewModel: ObservableObject {
    @Published var registersStatus: [RegisterStatus] = []
    
    let valueConsole = ValueLabelConsole()
    var mapper:ValueLabelMapper? = nil
    let node: Node
    
    public init(node: Node) {
        self.node = node
    }
    
    
    public func retrieveLabelData(type: RegisterDemoType) {
        let commandToSend: String = switch type {
        case .mlc:
            "getMLCLabels"
        case .fsm:
            "getFSMLabels"
        case .stredl:
            "getSTREDLLabels"
        }
        
        BlueManager.shared.sendMessage(
            commandToSend,
            to: node,
            completion:  DebugConsoleCallback(
                timeOut: 2.0,
                onCommandResponds: { text in
                    self.mapper = self.valueConsole.buildRegisterMapperFromString(text)
                    if !self.registersStatus.isEmpty {
                        //we need to re-write the registerStatus with the new mapper
                        self.updateRegistersStatus(registerStatus: self.registersStatus.map { $0.value })
                    }
                }, onCommandError: {
                    print("ERROR")
                }
            )
        )
    }
    
    func evaluateSample(_ sample: AnyFeatureSample) {
        switch sample {
        case let sample as FeatureSample<MachineLearningCoreData>:
            guard let registerStatus = sample.data?.registerStatus else { return }
            updateRegistersStatus(registerStatus: registerStatus)
            
        case let sample as FeatureSample<FiniteStateMachineData>:
            guard let registerStatus = sample.data?.registerStatus else { return }
            updateRegistersStatus(registerStatus: registerStatus)
            
        case let sample as FeatureSample<STREDLData>:
            guard let registerStatus = sample.data?.registerStatus else { return }
            updateRegistersStatus(registerStatus: registerStatus)
        default:
            return
        }
    }
    
    //Used when there will be a new sample from the feature
    private func updateRegistersStatus(registerStatus: [FeatureField<UInt8>]) {
        self.registersStatus = registerStatus.indices.compactMap { index in
            guard let rawValue = registerStatus[index].value else { return nil }
            
            let algoName = mapper?.algorithmName(register: ValueLabelMapper.RegisterIndex(index))
            let valueName = mapper?.valueName(register: ValueLabelMapper.RegisterIndex(index), value: rawValue)
            
            return RegisterStatus(
                registerId: index,
                value: rawValue,
                algorithmName: algoName,
                label: valueName
            )
        }
    }
    
    //Used when we received the labels from the debug console and we want to update the UI
    // even withtout receiving a new sample from the feature
    private func updateRegistersStatus(registerStatus: [UInt8?]) {
        self.registersStatus = registerStatus.indices.compactMap { index in
            guard let rawValue = registerStatus[index] else { return nil }
            
            let algoName = mapper?.algorithmName(register: ValueLabelMapper.RegisterIndex(index))
            let valueName = mapper?.valueName(register: ValueLabelMapper.RegisterIndex(index), value: rawValue)
            
            return RegisterStatus(
                registerId: index,
                value: rawValue,
                algorithmName: algoName,
                label: valueName
            )
        }
    }
}
