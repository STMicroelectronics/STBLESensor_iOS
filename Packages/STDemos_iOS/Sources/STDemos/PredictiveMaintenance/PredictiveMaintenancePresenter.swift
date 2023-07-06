//
//  PredictiveMaintenancePresenter.swift
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

final class PredictiveMaintenancePresenter: DemoPresenter<PredictiveMaintenanceViewController> {
    private static let SPEED_VALUE_FORMAT = {
        return  NSLocalizedString("RMS Speed: %.2f mm/s",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveMaintenancePresenter.self),
                                  value: "RMS Speed: %.2f mm/s",
                                  comment: "RMS Speed: %.2f mm/s");
    }()
    private static let ACCELERATION_VALUE_FORMAT = {
        return  NSLocalizedString("Acc Peak: %.2f m/s^2",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveMaintenancePresenter.self),
                                  value: "Acc Peak: %.2f m/s^2",
                                  comment: "Acc Peak: %.2f m/s^2");
    }()
    private static let FREQUENCY_DOMAIN_VALUE_FORMAT = {
        return  NSLocalizedString("Max Amplitude: %.2f m/s^2",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveMaintenancePresenter.self),
                                  value: "Max Amplitude: %.2f m/s^2",
                                  comment: "Max Amplitude: %.2f m/s^2");
    }()
    private static let FREQUENCY_DOMAIN_FREQ_VALUE_FORMAT = {
        return  NSLocalizedString("Frequency: %.2f Hz",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveMaintenancePresenter.self),
                                  value: "Frequency: %.2f Hz",
                                  comment: "Frequency: %.2f Hz");
    }()
}

// MARK: - PredictiveMaintenanceViewControllerDelegate
extension PredictiveMaintenancePresenter: PredictiveMaintenanceDelegate {

    func load() {
        
        demo = .predictiveMaintenance
        
        demoFeatures = param.node.characteristics.features(with: Demo.predictiveMaintenance.features)
        
        view.configureView()
    }

    func updatePredictiveMaintenanceUI(with sample: STBlueSDK.AnyFeatureSample?) {
        if let sample = sample as? FeatureSample<PredictiveSpeedStatusData>,
           let data = sample.data {
            
            if let statusX = data.statusSpeedX.value {
                view.speedStatusView.xImage.image = statusX.image ?? PredictiveStatus.unknown.image
                view.speedStatusView.xLabel.text = String(statusX.description)
            }
            if let statusY = data.statusSpeedX.value {
                view.speedStatusView.yImage.image = statusY.image ?? PredictiveStatus.unknown.image
                view.speedStatusView.yLabel.text = String(statusY.description)
            }
            if let statusZ = data.statusSpeedX.value {
                view.speedStatusView.zImage.image = statusZ.image ?? PredictiveStatus.unknown.image
                view.speedStatusView.zLabel.text = String(statusZ.description)
            }
            
            //view.speedStatusView.xMeasure.text = String(format: PredictiveMaintenancePresenter.SPEED_VALUE_FORMAT, Float(data.rmsSpeedX.value ?? 0.0))
            view.speedStatusView.xMeasure.text = String(format: PredictiveMaintenancePresenter.SPEED_VALUE_FORMAT, Float(data.rmsSpeedX.value ?? 0.0))
            view.speedStatusView.yMeasure.text = String(format: PredictiveMaintenancePresenter.SPEED_VALUE_FORMAT, Float(data.rmsSpeedY.value ?? 0.0))
            view.speedStatusView.zMeasure.text = String(format: PredictiveMaintenancePresenter.SPEED_VALUE_FORMAT, Float(data.rmsSpeedZ.value ?? 0.0))
            
        } else if let sample = sample as? FeatureSample<PredictiveAccelerationStatusData>,
            let data = sample.data {
            
              if let statusX = data.statusAccX.value {
                  view.accPeakStatusView.xImage.image = statusX.image ?? PredictiveStatus.unknown.image
                  view.accPeakStatusView.xLabel.text = String(statusX.description)
              }
              if let statusY = data.statusAccY.value {
                  view.accPeakStatusView.yImage.image = statusY.image ?? PredictiveStatus.unknown.image
                  view.accPeakStatusView.yLabel.text = String(statusY.description)
              }
              if let statusZ = data.statusAccZ.value {
                  view.accPeakStatusView.zImage.image = statusZ.image ?? PredictiveStatus.unknown.image
                  view.accPeakStatusView.zLabel.text = String(statusZ.description)
              }
              
            view.accPeakStatusView.xMeasure.text = String(format: PredictiveMaintenancePresenter.ACCELERATION_VALUE_FORMAT, Float(data.accelerationX.value ?? 0.0))
            view.accPeakStatusView.yMeasure.text = String(format: PredictiveMaintenancePresenter.ACCELERATION_VALUE_FORMAT, Float(data.accelerationY.value ?? 0.0))
            view.accPeakStatusView.zMeasure.text = String(format: PredictiveMaintenancePresenter.ACCELERATION_VALUE_FORMAT, Float(data.accelerationZ.value ?? 0.0))
            
        } else if let sample = sample as? FeatureSample<PredictiveFrequencyDomainStatusData>,
           let data = sample.data {
            
            if let statusX = data.statusX.value {
                view.frequencyDomainStatusView.xImage.image = statusX.image ?? PredictiveStatus.unknown.image
                view.frequencyDomainStatusView.xLabel.text = String(statusX.description)
            }
            if let statusY = data.statusX.value {
                view.frequencyDomainStatusView.yImage.image = statusY.image ?? PredictiveStatus.unknown.image
                view.frequencyDomainStatusView.yLabel.text = String(statusY.description)
            }
            if let statusZ = data.statusX.value {
                view.frequencyDomainStatusView.zImage.image = statusZ.image ?? PredictiveStatus.unknown.image
                view.frequencyDomainStatusView.zLabel.text = String(statusZ.description)
            }
            
            view.frequencyDomainStatusView.xMeasure.text = String(format: PredictiveMaintenancePresenter.FREQUENCY_DOMAIN_VALUE_FORMAT, Float(data.valueX.value ?? 0.0))
            view.frequencyDomainStatusView.yMeasure.text = String(format: PredictiveMaintenancePresenter.FREQUENCY_DOMAIN_VALUE_FORMAT, Float(data.valueY.value ?? 0.0))
            view.frequencyDomainStatusView.zMeasure.text = String(format: PredictiveMaintenancePresenter.FREQUENCY_DOMAIN_VALUE_FORMAT, Float(data.valueZ.value ?? 0.0))
            
            view.frequencyDomainStatusView.xFrequency.text = String(format: PredictiveMaintenancePresenter.FREQUENCY_DOMAIN_FREQ_VALUE_FORMAT, Float(data.freqX.value ?? 0.0))
            view.frequencyDomainStatusView.yFrequency.text = String(format: PredictiveMaintenancePresenter.FREQUENCY_DOMAIN_FREQ_VALUE_FORMAT, Float(data.freqY.value ?? 0.0))
            view.frequencyDomainStatusView.zFrequency.text = String(format: PredictiveMaintenancePresenter.FREQUENCY_DOMAIN_FREQ_VALUE_FORMAT, Float(data.freqZ.value ?? 0.0))
        }
    }
}

extension PredictiveStatus {
    public var image: UIImage? {
        switch self {
        case .good:
            return ImageLayout.image(with: "predictive_good", in: .module)
        case .warning:
            return ImageLayout.image(with: "predictive_warning", in: .module)
        case .bad:
            return ImageLayout.image(with: "predictive_bad", in: .module)
        case .unknown:
            return ImageLayout.image(with: "predictive_warning", in: .module)
        }
    }
}
