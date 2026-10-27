//
//  AssetTrackingEventViewModel.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK

class AssetTrackingEventViewModel: ObservableObject {
    @Published var assetTrackingEvents: [AssetTrackingEventDetected] = []
    @Published var lastTimestampEvent: String = "-"
    
    @Published var fallTotalEvents: Int = 0
    @Published var shockTotalEvents: Int = 0
    
    @Published var currentStatus: String?
    @Published var amps: Int?
    @Published var powerIndex: Int?
    
    func evaluateEvent(_ sample: FeatureSample<AssetTrackingEventData>) {
        if let data = sample.data,
           let event = data.event.value {
            switch event.type {
                
            case .fall:
                guard let fall = event.fall else { break }
                let currentTimestamp = getCurrentTimestamp()
                lastTimestampEvent = currentTimestamp
                assetTrackingEvents.append(
                    AssetTrackingEventDetected(
                        timestamp: currentTimestamp,
                        fall: AssetTrackingFallEventDetected(height: fall.heightCm),
                        shock: nil)
                )
                assetTrackingEvents.sort { $0.timestamp > $1.timestamp }
                fallTotalEvents += 1
                
            case .shock:
                guard let shock = event.shock else { break }
                let currentTimestamp = getCurrentTimestamp()
                lastTimestampEvent = currentTimestamp
                assetTrackingEvents.append(
                    AssetTrackingEventDetected(
                        timestamp: currentTimestamp,
                        fall: nil,
                        shock: AssetTrackingShockEventDetected(
                            duration: shock.durationMSec,
                            intensityNorm: shock.intensityG.computeNorm(),
                            intensity: shock.intensityG,
                            angles: shock.angles,
                            orientation: shock.orientations
                        )
                    )
                )
                assetTrackingEvents.sort { $0.timestamp > $1.timestamp }
                shockTotalEvents += 1
                
            case .stationary:
                guard let status = event.status else { break }
                currentStatus = event.type.description
                amps = status.current
                powerIndex = status.powerIndex
                
            case .motion:
                guard let status = event.status else { break }
                currentStatus = event.type.description
                amps = status.current
                powerIndex = status.powerIndex
                
            case .reset:
                clearEvents()
                
            case .null:
                break
            }
        }
    }

    func clearEvents() {
        assetTrackingEvents.removeAll()
        lastTimestampEvent = "-"
        fallTotalEvents = 0
        shockTotalEvents = 0
    }
    
    private func getCurrentTimestamp() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}
