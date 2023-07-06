//
//  NEAIAnomalyDetectionModelExtension.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STBlueSDK

extension PhaseType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .IDLE:
            return Localizer.NeaiAnomalyDetection.Aiengine.Phase.idle.localized
        case .LEARNING:
            return Localizer.NeaiAnomalyDetection.Aiengine.Phase.learning.localized
        case .DETECTION:
            return Localizer.NeaiAnomalyDetection.Aiengine.Phase.detection.localized
        case .IDLE_TRAINED:
            return Localizer.NeaiAnomalyDetection.Aiengine.Phase.idleTrained.localized
        case .BUSY:
            return Localizer.NeaiAnomalyDetection.Aiengine.Phase.busy.localized
        case .NULL:
            return Localizer.NeaiAnomalyDetection.Aiengine.Phase.null.localized
        }
    }
}

extension StateType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .OK:
            return Localizer.NeaiAnomalyDetection.Aiengine.State.ok.localized
        case .INIT_NOT_CALLED:
            return Localizer.NeaiAnomalyDetection.Aiengine.State.initNotCalled.localized
        case .BOARD_ERROR:
            return Localizer.NeaiAnomalyDetection.Aiengine.State.boardError.localized
        case .KNOWLEDGE_ERROR:
            return Localizer.NeaiAnomalyDetection.Aiengine.State.boardError.localized
        case .NOT_ENOUGH_LEARNING:
            return Localizer.NeaiAnomalyDetection.Aiengine.State.notEnoughLearning.localized
        case .MINIMAL_LEARNING_DONE:
            return Localizer.NeaiAnomalyDetection.Aiengine.State.minimalLearningDone.localized
        case .UNKOWN_ERROR:
            return Localizer.NeaiAnomalyDetection.Aiengine.State.unknownError.localized
        case .NULL:
            return Localizer.NeaiAnomalyDetection.Aiengine.State.null.localized
        }
    }
}

extension StatusType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .NORMAL:
            return Localizer.NeaiAnomalyDetection.Results.Status.normal.localized
        case .ANOMALY:
            return Localizer.NeaiAnomalyDetection.Results.Status.anomaly.localized
        case .NULL:
            return Localizer.NeaiAnomalyDetection.Results.Status.null.localized
        }
    }
}
