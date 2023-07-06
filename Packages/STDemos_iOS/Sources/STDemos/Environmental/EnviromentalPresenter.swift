//
//  EnviromentalPresenter.swift
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

final class EnviromentalPresenter: DemoPresenter<EnviromentalViewController> {

}

// MARK: - EnviromentalDelegate
extension EnviromentalPresenter: EnviromentalDelegate {

    func load() {

        demo = .environmental

        view.title = demo?.title

        demoFeatures = param.node.characteristics.features(with: Demo.environmental.features)

        view.configureView()
        view.configureView(with: demoFeatures)
    }

    func update(with feature: EnvironmentalFeature) {
        if let index = demoFeatures.firstIndex(where: { $0.type.mask == feature.type.mask }),
           let view = view.mainView.stackView.arrangedSubviews[index] as? SensorView {

            view.imageView.image = UIImage(named: feature.image)
            view.uomLabel.isHidden = !feature.isSecondaryUomEnabled
            view.uomSwitch.isHidden = !feature.isSecondaryUomEnabled

            var offset: Double = 0.0

            if let text = view.offsetTextField.text {
                offset = Double(text) ?? 0.0
            }

            if feature.isSecondaryUomEnabled {
                view.valueLabel.text = feature.valueString(with: view.uomSwitch.isOn, offset: offset)
            } else {
                view.valueLabel.text = feature.valueString(with: false, offset: offset)
            }
        }
    }
}

extension TemperatureFeature: EnvironmentalFeature {

    public var image: String {
        "img_enviromental_temperature"
    }

    public var missingImage: String {
        "img_enviromental_temperature_missing"
    }

    public var isSecondaryUomEnabled: Bool {
        true
    }

    public func valueString(with secondaryUom: Bool, offset: Double) -> String {
        guard let sample = sample,
              let temperature = sample.data?.temperature.value else { return "" }

        let measurement = Measurement(value: Double(temperature),
                                      unit: UnitTemperature.celsius)

        let value = secondaryUom ? measurement.converted(to: .fahrenheit).value : measurement.value

        return String(format: "%.2f [%@]", value + offset, secondaryUom ? "°F" : "°C")
    }
}

extension PressureFeature: EnvironmentalFeature {
    public var image: String {
        "img_enviromental_pressure"
    }

    public var missingImage: String {
        "img_enviromental_pressure_missing"
    }

    public var isSecondaryUomEnabled: Bool {
        false
    }

    public func valueString(with secondaryUom: Bool, offset: Double) -> String {
        guard let sample = sample,
              let pressure = sample.data?.pressure.value else { return "" }

        return String(format: "%.2f [%@]", Double(pressure) + offset, "mBar")

    }
}

extension HumidityFeature: EnvironmentalFeature {
    public var image: String {
        "img_enviromental_humidity"
    }

    public var missingImage: String {
        "img_enviromental_humidity_missing"
    }

    public var isSecondaryUomEnabled: Bool {
        false
    }

    public func valueString(with secondaryUom: Bool, offset: Double) -> String {
        guard let sample = sample,
              let humidity = sample.data?.humidity.value else { return "" }

        return String(format: "%.2f [%@]", Double(humidity) + offset, "%")

    }
}
