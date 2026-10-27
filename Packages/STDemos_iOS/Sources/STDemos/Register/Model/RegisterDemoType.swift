//
//  RegisterDemoType.swift
//  STDemos
//
//  Created by Luca Pezzoni on 21/10/2026.
//

import STBlueSDK

enum RegisterDemoType {
    case mlc
    case fsm
    case stredl
}

extension RegisterDemoType {
    public var featureName: String {
        switch self {
        case .mlc:
            return String(describing: MachineLearningCoreFeature.self)
        case .fsm:
            return String(describing: FiniteStateMachineFeature.self)
        case .stredl:
            return String(describing: STREDLFeature.self)
        }
    }
}
