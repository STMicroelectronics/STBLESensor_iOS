//
//  FlowInputOptionPresenter.swift
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

final class FlowInputOptionPresenter: BasePresenter<FlowInputOptionViewController, SensorAndNodeParam> {
    var customOdrChecked: Bool = false
}

// MARK: - FlowInputOptionViewControllerDelegate
extension FlowInputOptionPresenter: FlowInputOptionDelegate {
    
    func load() {
        view.configureView()
        
        view.title = param.sensor.descr
        
        configureRegConfig()
        configureAcquisitionTime()
        configurePowerMode()
        configureFullScale()
    }
    
    func doneButtonTapped() {
        let type = view.regConfigView.type
        
        if (type == .MLCVirtualSensor || type == .FSMVirtualSensor) {
            let labelMapper = ValueLabelMapper()
            
            for item in view.regConfigView.labelStackView.arrangedSubviews {
                if let algoView = item as? AlgoLabelView {
                    labelMapper.addRegisterName(register: algoView.index, label: algoView.algoNameTextField.text ?? "")
                    algoView.labelRows.forEach {
                        
                        if let value = UInt8($0.outputTextField.text ?? "0"), let label = $0.labelTextField.text {
                            labelMapper.addLabel(register: algoView.index, value: value, label: label)
                        }
                    }
                }
            }
            
            let labels = UcfParser.encodeLabelMapper(type: type, labelMapper: labelMapper)
            if (type == .MLCVirtualSensor) {
                param.sensor.configuration?.mlcLabels = labels
            } else {
                param.sensor.configuration?.fsmLabels = labels
            }
            
            param.sensor.configuration?.regConfig = view.regConfigView.parser?.regConfig
            param.sensor.configuration?.ucfFilename = view.regConfigView.parser?.ucfFilename
            
        }
        
        guard !customOdrChecked || (customOdrChecked && view.customOdrTextField.validate().boolValue()) else { return }
        
        self.view.dismiss(animated: true)
    }
    
    func cancelButtonTapped() {
        self.view.dismiss(animated: true)
    }
}

extension FlowInputOptionPresenter {
    
    func configureRegConfig() {
        let param = param.sensor
        
        if ((param.configuration?.regConfig) == nil) { return }
        
        if let _ = param.configuration?.mlcLabels {
            view.regConfigView.initView(type: .MLCVirtualSensor, regConfig: param.configuration?.regConfig ?? "", ucfFilename: param.configuration?.ucfFilename ?? "", labels: param.configuration?.mlcLabels ?? "")
            view.stackView.addArrangedSubview(view.regConfigView)
        } else {
            if let _ = param.configuration?.fsmLabels {
                view.regConfigView.initView(type: .FSMVirtualSensor, regConfig: param.configuration?.regConfig ?? "", ucfFilename: param.configuration?.ucfFilename ?? "", labels: param.configuration?.fsmLabels ?? "")
                view.stackView.addArrangedSubview(view.regConfigView)
            } else { return }
        }
    }
    
    func configureAcquisitionTime() {
        let sensor = param.sensor
        if sensor.acquisitionTime != nil {
            let acquisitionTimeTextField = TextField(frame: .zero)
            acquisitionTimeTextField.titleText = "Acquisition Time (minutes)"
            var acquisitionTimeConfiguration: String = "0"
            if let configuration = sensor.configuration?.acquisitionTime {
                acquisitionTimeConfiguration = "\(configuration / 60)"
            }
            acquisitionTimeTextField.text = acquisitionTimeConfiguration
            acquisitionTimeTextField.keyboardType = .decimalPad
            acquisitionTimeTextField.addDoneButtonToKeyboard()
            
            acquisitionTimeTextField.configure { text in
                if let text = text, acquisitionTimeTextField.isValid {
                    sensor.configuration?.acquisitionTime = Int(text)
                }
            }
            view.stackView.addArrangedSubview(acquisitionTimeTextField.embedInView(with: UIEdgeInsets(top: 30.0, left: 0.0, bottom: 0.0, right: 0.0)))
        }
    }
    
    func configurePowerMode() {
        if let powerModes = param.sensor.powerMode, let selectedPowerMode = powerModes.first(where: { $0.mode == param.sensor.configuration?.powerMode }) {
            
            let sensor = param.sensor
            
            // Se è diversa da none mostro radio per selezionarla
            if selectedPowerMode.mode != .none {
                let powerModeCheckboxes: CheckBoxGroup = CheckBoxGroup.createFromNib()
                powerModeCheckboxes.configure(title: "Power Mode",
                                              items: powerModes,
                                              selectedItems: [selectedPowerMode],
                                              singleSelection: true) { selectedItems in
                    if let result = selectedItems.first as? PowerMode {
                        sensor.configuration?.powerMode = result.mode
                        sensor.configuration?.odr = nil
                        sensor.configuration?.filters = nil
                        self.configureOrd(sensor, with: result)
                    }
                    
                }
                view.stackView.addArrangedSubview(powerModeCheckboxes)
            }
            
            view.stackView.addArrangedSubview(view.odrPicker)
            view.stackView.addArrangedSubview(view.customOdrStackView)
            
            view.customOdrStackView.spacing = 4.0
            view.customOdrMinLabel.font = FontLayout.regular.withSize(12.0)
            view.customOdrMinLabel.textColor = ColorLayout.text.auto
            
            view.customOdrCheckBoxRow.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            view.customOdrTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            view.customOdrMinLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            view.customOdrStackView.addArrangedSubview(view.customOdrCheckBoxRow)
            view.customOdrStackView.addArrangedSubview(view.customOdrTextField)
            view.customOdrStackView.addArrangedSubview(view.customOdrMinLabel)
            
            view.stackView.addArrangedSubview(view.lowPassPicker)
            view.stackView.addArrangedSubview(view.highPassPicker)
            
            customOdrChecked = sensor.configuration?.oneShotTime != nil
            configureOrd(sensor, with: selectedPowerMode)
        }
    }
    
    func configureFullScale() {
        if let fullScales = param.sensor.fullScales {
            
            let sensor = param.sensor
            
            let fullScalePicker = Picker()
            let fullScaleUnit = sensor.fullScaleUm
            var fullScalePickerSelected: FullScalePickable?
            if let selected = sensor.configuration?.fullScale {
                fullScalePickerSelected = FullScalePickable(value: selected, unit: fullScaleUnit)
            }
            fullScalePicker.configure(title: "Full-scale (FS)",
                                      items: fullScales.map { FullScalePickable(value: $0 ,unit: fullScaleUnit) },
                                      selected: fullScalePickerSelected) { pickable in
                if let fullScaleResult = pickable as? FullScalePickable {
                    sensor.configuration?.fullScale = fullScaleResult.value
                }
            }
            view.stackView.addArrangedSubview(fullScalePicker)
        }
    }
    
    func configureOrd(_ sensor: Sensor, with powerMode: PowerMode) {
        // ODR
        // Dipende dalla Power Mode selezionata
        let odrs = powerMode.odrs

        var odrPickerSelected: OdrPickable?
        if let first = odrs.first {
            odrPickerSelected = OdrPickable(value: first)
        }
        if let selected = sensor.configuration?.odr {
            odrPickerSelected = OdrPickable(value: selected)
        }
        view.odrPicker.configure(title: "ODR",
                            items: odrs.map { OdrPickable(value: $0) },
                            selected: odrPickerSelected) { pickable in
                                
                                sensor.configuration?.filters = nil
                                
                                if let odrResult = pickable as? OdrPickable {
                                    sensor.configuration?.odr = odrResult.value
                                    self.configureFilters(sensor, with: powerMode, selectedOdr: odrResult)
                                }
                                
        }

        // Controllo se utente può mettere ODR personalizzato
        if let minCustomOdr = powerMode.minCustomOdr {
            view.customOdrStackView.axis = .horizontal

            view.customOdrCheckBoxRow.configureWith(FakeCheckable(), checked: customOdrChecked, singleSelection: false)
            view.customOdrCheckBoxRow.addCompletion { result in
                self.customOdrChecked = result
                self.configureOrd(sensor, with: powerMode)
                return
            }

            view.customOdrTextField.configure { text in
                guard let text = text else { return }
                sensor.configuration?.oneShotTime = self.view.customOdrTextField.validate().boolValue() ? Int(text) : nil
            }
            view.customOdrTextField.titleText = nil
            view.customOdrTextField.placeholder = "Custom ODR Value"
            view.customOdrTextField.keyboardType = .decimalPad
            view.customOdrTextField.addDoneButtonToKeyboard()
            view.customOdrTextField.validators = [
                MinValueValidator(with: minCustomOdr, errorMessage: "This value is too low")
            ]
            view.customOdrMinLabel.text = "min value \(minCustomOdr) s"
        } else {
            view.customOdrStackView.isHidden = true
        }

        view.odrPicker.active = !customOdrChecked
        view.customOdrTextField.isEnabled = customOdrChecked
        view.customOdrTextField.text = customOdrChecked ? "\(sensor.configuration?.oneShotTime ?? powerMode.minCustomOdr ?? 0)" : nil
        
        if !customOdrChecked {
            view.customOdrTextField.isValid = true
            sensor.configuration?.oneShotTime = nil
        }
        
        self.configureFilters(sensor, with: powerMode, selectedOdr: odrPickerSelected)
    }
    
    func configureFilters(_ sensor: Sensor, with powerMode: PowerMode, selectedOdr: OdrPickable?) {
        // Filtri
        // Dipendono da Power Mode e ODR
        let filters = PersistanceService.shared.getFiltersBy(runningNode: param.node, sensor.identifier,
                                                             powerMode: powerMode.mode,
                                                             odr: Double(selectedOdr?.value ?? 0.0)
        )
        
        if let lowPass = filters?.lowPass, !lowPass.isEmpty {
            var lowPassItems: [Pickable] = [EmptyPickable()]
            lowPassItems.append(contentsOf: lowPass)
            var lowPassSelected = lowPassItems.first
            if let selected = sensor.configuration?.filters?.lowPass {
                lowPassSelected = selected
            }
            view.lowPassPicker.configure(title: "LowPass Filter",
                                    items: lowPassItems,
                                    selected: lowPassSelected) { pickable in
                                        if let result = pickable as? Pass {
                                            sensor.configuration?.update(lowPass: result)
                                        } else if pickable as? EmptyPickable != nil {
                                            sensor.configuration?.update(lowPass: nil)
                                        }
            }
            view.lowPassPicker.isHidden = false
        } else {
            view.lowPassPicker.isHidden = true
        }
        
        if let highPass = filters?.highPass, !highPass.isEmpty {
            var highPassItems: [Pickable] = [EmptyPickable()]
            highPassItems.append(contentsOf: highPass)
            var highPassSelected = highPassItems.first
            if let selected = sensor.configuration?.filters?.highPass {
                highPassSelected = selected
            }
            view.highPassPicker.configure(title: "HighPass Filter",
                                     items: highPassItems,
                                     selected: highPassSelected) { pickable in
                                        if let result = pickable as? Pass {
                                            sensor.configuration?.update(highPass: result)
                                        } else if pickable as? EmptyPickable != nil {
                                            sensor.configuration?.update(highPass: nil)
                                        }
            }
            view.highPassPicker.isHidden = false
        } else {
            view.highPassPicker.isHidden = true
        }
    }
}
