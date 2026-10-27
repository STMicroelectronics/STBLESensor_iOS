//
//  CarryPositionDemoViewModel.swift
//  STDemos
//
//  Created by Luca Pezzoni on 19/10/2026.
//

import Foundation
import STBlueSDK

class CarryPositionDemoViewModel: ObservableObject {
    @Published var position: CarryPositionType = .unknown

    func evaluateSample(_ sample: FeatureSample<CarryPositionData>) {
        guard let value = sample.data?.position.value else {return }
        self.position = value
    }
}
