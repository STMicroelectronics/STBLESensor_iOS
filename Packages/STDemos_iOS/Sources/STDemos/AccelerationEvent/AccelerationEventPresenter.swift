//
//  AccelerationEventPresenter.swift
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
import STCore

final class AccelerationEventPresenter: DemoPresenter<AccelerationEventViewController> {

    private static let NUCLEO_SUPPORTED_EVENT : [AccelerationEventCommand] = [
        AccelerationEventCommand.none,
        AccelerationEventCommand.multiple(enabled: true),
        AccelerationEventCommand.orientation(enabled: true),
        AccelerationEventCommand.doubleTap(enabled: true),
        AccelerationEventCommand.freeFall(enabled: true),
        AccelerationEventCommand.pedometer(enabled: true),
        AccelerationEventCommand.singleTap(enabled: true),
        AccelerationEventCommand.tilt(enabled: true),
        AccelerationEventCommand.wakeUp(enabled: true)
    ]
    
    private static let SENSORTILEBOX_SUPPORTED_EVENT : [AccelerationEventCommand] = [
        AccelerationEventCommand.none,
        AccelerationEventCommand.multiple(enabled: true),
        AccelerationEventCommand.orientation(enabled: true),
        AccelerationEventCommand.doubleTap(enabled: true),
        AccelerationEventCommand.freeFall(enabled: true),
        AccelerationEventCommand.singleTap(enabled: true),
        AccelerationEventCommand.tilt(enabled: true),
        AccelerationEventCommand.wakeUp(enabled: true)
    ]
    
    private static let STWIN_SUPPORTED_EVENT : [AccelerationEventCommand] = [
        AccelerationEventCommand.none,
        AccelerationEventCommand.freeFall(enabled: true),
        AccelerationEventCommand.pedometer(enabled: true),
        AccelerationEventCommand.singleTap(enabled: true),
        AccelerationEventCommand.tilt(enabled: true),
        AccelerationEventCommand.wakeUp(enabled: true)
    ]
    
    private static let IDB008_SUPPORTED_EVENT : [AccelerationEventCommand] = [
        AccelerationEventCommand.none,
        AccelerationEventCommand.freeFall(enabled: true),
        AccelerationEventCommand.pedometer(enabled: true),
        AccelerationEventCommand.singleTap(enabled: true),
        AccelerationEventCommand.tilt(enabled: true),
        AccelerationEventCommand.wakeUp(enabled: true)
    ]
    
    private static let BCN002V1_SUPPORTED_EVENT : [AccelerationEventCommand] = [
        AccelerationEventCommand.none,
        AccelerationEventCommand.freeFall(enabled: true),
        AccelerationEventCommand.pedometer(enabled: true),
        AccelerationEventCommand.singleTap(enabled: true),
        AccelerationEventCommand.tilt(enabled: true),
        AccelerationEventCommand.wakeUp(enabled: true)
    ]
    
    private static let PROTEUS_SUPPORTED_EVENT : [AccelerationEventCommand] = [
        AccelerationEventCommand.none,
        AccelerationEventCommand.wakeUp(enabled: true)
    ]
}

// MARK: - AccelerometerEventViewControllerDelegate
extension AccelerationEventPresenter: AccelerationEventDelegate {
    
    func load() {
        
        demo = .accelerationEvent
        
        demoFeatures = param.node.characteristics.features(with: Demo.accelerationEvent.features)
        
        view.configureView()
        
    }

    func updateAccEventUI(with sample: AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<AccelerationEventData>,
           let data = sample.data {
            if let event = data.event.value {
                if view.mCurrentEvent.isOrientation {
                    if event == .orientationBottomLeft || event == .orientationBottomRight ||
                        event == .orientationDown || event == .orientationTopLeft || event == .orientationTopRight ||
                        event == .orientationUp {
                        if let orientationImage = event.image {
                            view.accEventSingleView.image.image = orientationImage
                        }
                    }
                } else if event == .doubleTap && view.mCurrentEvent.isDoubleTap {
                    view.accEventSingleView.image.shake()
                } else if event == .doubleTap && view.mCurrentEvent.isDoubleTap {
                    view.accEventSingleView.image.shake()
                } else if event == .freeFall && view.mCurrentEvent.isFreeFall {
                    view.accEventSingleView.image.shake()
                } else if event == .pedometer && view.mCurrentEvent.isPedometer {
                    view.accEventSingleView.image.shake()
                } else if event == .singleTap && view.mCurrentEvent.isSingleTap {
                    view.accEventSingleView.image.shake()
                } else if event == .tilt && view.mCurrentEvent.isTilt {
                    view.accEventSingleView.image.shake()
                } else if event == .wakeUp && view.mCurrentEvent.isWakeUp {
                    view.accEventSingleView.image.shake()
                } else if view.mCurrentEvent.isMultiple {
                    updateValuesInMultipleView(data, event)
                }
            }
        }
    }
    
    func getSupportedEvents() -> [AccelerationEventCommand]? {
        switch param.node.type {
        case .stEvalIDB008VX:
            return AccelerationEventPresenter.IDB008_SUPPORTED_EVENT
        case .stEvalBCN002V1:
            return AccelerationEventPresenter.BCN002V1_SUPPORTED_EVENT
        case .sensorTileBox, .sensorTileBoxPro, .sensorTileBoxProB, .sensorTileBoxProC:
            return AccelerationEventPresenter.SENSORTILEBOX_SUPPORTED_EVENT
        case .stEvalSTWINKIT1, .stEvalSTWINKT1B, .stWinBox, .stWinBoxB:
            return AccelerationEventPresenter.STWIN_SUPPORTED_EVENT
        case .proteus:
            return AccelerationEventPresenter.PROTEUS_SUPPORTED_EVENT
        case .sensorTile, .blueCoin, .wb55NucleoBoard, .wba55CGNucleoBoard, .nucleo, .nucleoF401RE, .nucleoL476RG, .nucleoL053R8, .nucleoF446RE:
            return AccelerationEventPresenter.NUCLEO_SUPPORTED_EVENT
        default:
            return nil
        }
    }
    
    func getDefaultEvent() -> AccelerationEventCommand {
        switch param.node.type {
        case .stEvalIDB008VX:
            return AccelerationEventCommand.freeFall(enabled: true)
        case .sensorTile, .blueCoin, .wb55NucleoBoard, .wba55CGNucleoBoard, .nucleo, .nucleoF401RE, .nucleoF446RE, .nucleoL053R8, .nucleoL476RG, .sensorTileBox, .sensorTileBoxPro, .sensorTileBoxProB, .sensorTileBoxProC, .stEvalSTWINKIT1, .stEvalSTWINKT1B, .stWinBox, .stWinBoxB:
            return AccelerationEventCommand.orientation(enabled: true)
        case .stEvalBCN002V1, .proteus:
            return AccelerationEventCommand.wakeUp(enabled: true)
        default:
            return AccelerationEventCommand.none
        }
    }
    
    func changeAccelerationEvent() {
        var actions: [UIAlertAction] = []
        if let supportedEvents = view.supportedEvents {
            let accEventsTypes: [String] = supportedEvents.map { $0.description }
            for i in 0..<supportedEvents.count {
                actions.append(UIAlertAction.genericButton(accEventsTypes[i]) { [weak self] _ in
                    self?.updateRunningAccelerationEvent(supportedEvents[i])
                })
            }
            actions.append(UIAlertAction.cancelButton())
            UIAlertController.presentAlert(from: view.self, title: "Select Acceleration Event Type", actions: actions)
        }
    }
    
    func updateRunningAccelerationEvent(_ event: AccelerationEventCommand) {
        /// 1. Disable Current Command
        let commandToDisable = getDisableCommand(view.mCurrentEvent)
        sendAccelerationEventTypeCommand(commandToDisable)
        
        /// 2. Reaplace Current Command with Requester
        view.mCurrentEvent = event
        
        /// 3. Enable Current Command
        let commandToEnable = getEnableCommand(event)
        sendAccelerationEventTypeCommand(commandToEnable)
        
        /// 4. Handle UI
        if event.isMultiple {
            showMultipleView()
            view.accelerationTypeLabel.text = event.description
        } else {
            showSingleView()
            updateValuesInSingleView(event)
        }
    }
    
    private func showMultipleView(){
        view.containerAccEventSingleView.isHidden = true
        view.containerAccEventMultipleView.isHidden = false
    }
    
    private func showSingleView(){
        view.containerAccEventSingleView.isHidden = false
        view.containerAccEventMultipleView.isHidden = true
    }
    
    private func updateValuesInSingleView(_ event: AccelerationEventCommand) {
        view.accelerationTypeLabel.text = event.description
        if let accImage = event.image {
            view.accEventSingleView.image.image = accImage
        }
    }
    
    private func sendAccelerationEventTypeCommand(_ accEventCommand: AccelerationEventCommand) {

        if let accEventFeature = param.node.characteristics.first(with: AccelerationEventFeature.self) {
            
            if let accEventFeature = accEventFeature as? AccelerationEventFeature {
                accEventFeature.setPedometerStatus(accEventCommand.isPedometer)
            }
            
            BlueManager.shared.sendCommand(FeatureCommand(type: accEventCommand, data: accEventCommand.payload),
                                           to: param.node,
                                           feature: accEventFeature)
            
            Logger.debug(text: accEventCommand.description)
        }
    }
    
    private func updateValuesInMultipleView(_ data: AccelerationEventData, _ event: AccelerationEventType){
        if event == .orientationUp || event == .orientationDown || event == .orientationTopLeft ||
            event == .orientationTopRight || event == .orientationBottomLeft || event == .orientationBottomRight {
            view.accEventMultipleView.orientationImage.image = event.image
        }
        if event == .pedometer {
            view.accEventMultipleView.pedometerImage.shake()
            if let steps = data.steps.value {
                view.accEventMultipleView.pedometerLabel.text = "Steps: \(steps)"
            }
        }
        if event == .singleTap {
            view.accEventMultipleView.tapImage.shake()
        }
        if event == .freeFall {
            view.accEventMultipleView.freeFallImage.shake()
        }
        if event == .doubleTap {
            view.accEventMultipleView.doubleTapImage.shake()
        }
        if event == .tilt {
            view.accEventMultipleView.tiltImage.shake()
        }
    }
    
    
}

extension AccelerationEventPresenter {
    private func getDisableCommand(_ accEventCommand: AccelerationEventCommand) -> AccelerationEventCommand {
        switch accEventCommand {
        case .orientation(_):
            return AccelerationEventCommand.orientation(enabled: false)
        case .multiple(_):
            return AccelerationEventCommand.multiple(enabled: false)
        case .tilt(_):
            return AccelerationEventCommand.tilt(enabled: false)
        case .freeFall(_):
            return AccelerationEventCommand.freeFall(enabled: false)
        case .singleTap(_):
            return AccelerationEventCommand.singleTap(enabled: false)
        case .doubleTap(_):
            return AccelerationEventCommand.doubleTap(enabled: false)
        case .wakeUp(_):
            return AccelerationEventCommand.wakeUp(enabled: false)
        case .pedometer(_):
            return AccelerationEventCommand.pedometer(enabled: false)
        case .none:
            return AccelerationEventCommand.none
        }
    }
    
    private func getEnableCommand(_ accEventCommand: AccelerationEventCommand) -> AccelerationEventCommand {
        switch accEventCommand {
        case .orientation(_):
            return AccelerationEventCommand.orientation(enabled: true)
        case .multiple(_):
            return AccelerationEventCommand.multiple(enabled: true)
        case .tilt(_):
            return AccelerationEventCommand.tilt(enabled: true)
        case .freeFall(_):
            return AccelerationEventCommand.freeFall(enabled: true)
        case .singleTap(_):
            return AccelerationEventCommand.singleTap(enabled: true)
        case .doubleTap(_):
            return AccelerationEventCommand.doubleTap(enabled: true)
        case .wakeUp(_):
            return AccelerationEventCommand.wakeUp(enabled: true)
        case .pedometer(_):
            return AccelerationEventCommand.pedometer(enabled: true)
        case .none:
            return AccelerationEventCommand.none
        }
    }
}
