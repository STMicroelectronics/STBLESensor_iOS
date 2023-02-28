//
//  SensorOptionsViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 01/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class SensorOptionsViewController: OptionsViewController<Sensor> {

    var sensor: Sensor?
    var selectedPowerMode: PowerMode?

    let regConfigView: RegConfigView = RegConfigView.createFromNib()

    let odrPicker: Picker = Picker()
    let customOdrStackView: UIStackView = UIStackView()
    let customOdrCheckBoxRow: CheckBoxRow = CheckBoxRow.createFromNib()
    let customOdrTextField = TextField()
    let customOdrMinLabel = UILabel()
    let lowPassPicker: Picker = Picker()
    let highPassPicker: Picker = Picker()

    var customOdrChecked: Bool = false

    override func rightButtonPressed() {

        let type = regConfigView.type
        
        if (type == .MLCVirtualSensor || type == .FSMVirtualSensor) {
            let labelMapper = ValueLabelMapper()
            
            for item in regConfigView.labelStackView.arrangedSubviews {
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
                sensor?.configuration?.mlcLabels = labels
            } else {
                sensor?.configuration?.fsmLabels = labels
            }
            
            sensor?.configuration?.regConfig = regConfigView.parser?.regConfig
            sensor?.configuration?.ucfFilename = regConfigView.parser?.ucfFilename
            
        }
        
        guard !customOdrChecked || (customOdrChecked && customOdrTextField.validate().boolValue()) else { return }

        super.rightButtonPressed()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func configureView(with item: Sensor) {
        navigationItem.title = "input_options".localized()
        
        sensor = item
        
        configureRegConfig(with: item)
        configureAcquisitionTime(with: item)
        configurePowerMode(with: item)
        configureFullScale(with: item)
        
        regConfigView.delegate = self
    }
}

extension SensorOptionsViewController: RegConfigViewDelegate, UIDocumentPickerDelegate {
    func ucfPickerUserRequestFile() {
        let ucfPicker = UIDocumentPickerViewController(documentTypes: ["com.st.bluems.document.ucf"], in: .import)
        ucfPicker.delegate = self
        present(ucfPicker, animated: true, completion: nil)
    }
    
    public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentsAt urls:[URL]){
        if let selectedFile = urls.first{
            regConfigView.parseUcfFile(ucf: selectedFile)
        }
    }
    
    public func documentPicker(_ pickController:UIDocumentPickerViewController, didPickDocumentAt url:URL){
        regConfigView.parseUcfFile(ucf: url)
    }
}

private extension SensorOptionsViewController {
    
    func configureAcquisitionTime(with item: Sensor) {
        if item.acquisitionTime != nil {
            let acquisitionTimeTextField = TextField(frame: .zero)
            acquisitionTimeTextField.titleText = "acquisition_time".localized()
            var acquisitionTimeConfiguration: String = "0"
            if let configuration = item.configuration?.acquisitionTime {
                acquisitionTimeConfiguration = "\(configuration / 60)"
            }
            acquisitionTimeTextField.text = acquisitionTimeConfiguration
            acquisitionTimeTextField.keyboardType = .decimalPad
            acquisitionTimeTextField.addDoneButtonToKeyboard()
            
            acquisitionTimeTextField.configure { text in
                if let text = text, acquisitionTimeTextField.isValid {
                    item.configuration?.acquisitionTime = Int(text)
                }
            }
            stackView.addArrangedSubview(acquisitionTimeTextField.embedInView(with: UIEdgeInsets(top: 30.0, left: 0.0, bottom: 0.0, right: 0.0)))
        }
    }
    
    func loadUI(labels: String) {
        return
    }
    
    func configureRegConfig(with item: Sensor) {
        
        if ((item.configuration?.regConfig) == nil) { return }
        
        if let _ = item.configuration?.mlcLabels {
            regConfigView.initView(type: .MLCVirtualSensor, regConfig: item.configuration?.regConfig ?? "", ucfFilename: sensor?.configuration?.ucfFilename ?? "", labels: sensor?.configuration?.mlcLabels ?? "")
            stackView.addArrangedSubview(regConfigView)
        } else {
            if let _ = item.configuration?.fsmLabels {
                regConfigView.initView(type: .FSMVirtualSensor, regConfig: item.configuration?.regConfig ?? "", ucfFilename: sensor?.configuration?.ucfFilename ?? "", labels: sensor?.configuration?.fsmLabels ?? "")
                stackView.addArrangedSubview(regConfigView)
            } else { return }
        }
    }
    
    func configurePowerMode(with item: Sensor) {
        if let powerModes = item.powerMode, let selectedPowerMode = powerModes.first(where: { $0.mode == item.configuration?.powerMode }) {
            
            // Se è diversa da none mostro radio per selezionarla
            if selectedPowerMode.mode != .none {
                let powerModeCheckboxes: CheckBoxGroup = CheckBoxGroup.createFromNib()
                powerModeCheckboxes.configure(title: "power_mode".localized(),
                                              items: powerModes,
                                              selectedItems: [selectedPowerMode],
                                              singleSelection: true) { selectedItems in
                                                if let result = selectedItems.first as? PowerMode {
                                                    item.configuration?.powerMode = result.mode
                                                    item.configuration?.odr = nil
                                                    item.configuration?.filters = nil
                                                    self.configureOrd(item, with: result)
                                                }
                                                
                }
                stackView.addArrangedSubview(powerModeCheckboxes)
            }
            
            stackView.addArrangedSubview(odrPicker)
            stackView.addArrangedSubview(customOdrStackView)
            
            customOdrStackView.spacing = 4.0
            customOdrMinLabel.font = currentTheme.font.regular.withSize(12.0)
            customOdrMinLabel.textColor = currentTheme.color.text
            
            customOdrCheckBoxRow.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            customOdrTextField.setContentHuggingPriority(.defaultLow, for: .horizontal)
            customOdrMinLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            
            customOdrStackView.addArrangedSubview(customOdrCheckBoxRow)
            customOdrStackView.addArrangedSubview(customOdrTextField)
            customOdrStackView.addArrangedSubview(customOdrMinLabel)
            
            stackView.addArrangedSubview(lowPassPicker)
            stackView.addArrangedSubview(highPassPicker)
            
            customOdrChecked = item.configuration?.oneShotTime != nil
            configureOrd(item, with: selectedPowerMode)
        }
    }
    
    func configureFullScale(with item: Sensor) {
        if let fullScales = item.fullScales {
            let fullScalePicker = Picker()
            let fullScaleUnit = item.fullScaleUm
            var fullScalePickerSelected: FullScalePickable?
            if let selected = item.configuration?.fullScale {
                fullScalePickerSelected = FullScalePickable(value: selected, unit: fullScaleUnit)
            }
            fullScalePicker.configure(title: "full_scale_extended".localized(),
                                      items: fullScales.map { FullScalePickable(value: $0 ,unit: fullScaleUnit) },
                                      selected: fullScalePickerSelected) { pickable in
                                        if let fullScaleResult = pickable as? FullScalePickable {
                                            item.configuration?.fullScale = fullScaleResult.value
                                        }
            }
            stackView.addArrangedSubview(fullScalePicker)
        }
    }

    func configureFilters(_ sensor: Sensor, with powerMode: PowerMode, selectedOdr: OdrPickable?) {
        // Filtri
        // Dipendono da Power Mode e ODR
        let filters = PersistanceService.shared.getFiltersBy(sensor.identifier,
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
            lowPassPicker.configure(title: "lowpass_filter".localized(),
                                    items: lowPassItems,
                                    selected: lowPassSelected) { pickable in
                                        if let result = pickable as? Pass {
                                            sensor.configuration?.update(lowPass: result)
                                        } else if pickable as? EmptyPickable != nil {
                                            sensor.configuration?.update(lowPass: nil)
                                        }
            }
            lowPassPicker.isHidden = false
        } else {
            lowPassPicker.isHidden = true
        }
        
        if let highPass = filters?.highPass, !highPass.isEmpty {
            var highPassItems: [Pickable] = [EmptyPickable()]
            highPassItems.append(contentsOf: highPass)
            var highPassSelected = highPassItems.first
            if let selected = sensor.configuration?.filters?.highPass {
                highPassSelected = selected
            }
            highPassPicker.configure(title: "highpass_filter".localized(),
                                     items: highPassItems,
                                     selected: highPassSelected) { pickable in
                                        if let result = pickable as? Pass {
                                            sensor.configuration?.update(highPass: result)
                                        } else if pickable as? EmptyPickable != nil {
                                            sensor.configuration?.update(highPass: nil)
                                        }
            }
            highPassPicker.isHidden = false
        } else {
            highPassPicker.isHidden = true
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
        odrPicker.configure(title: "odr".localized(),
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
            customOdrStackView.axis = .horizontal

            customOdrCheckBoxRow.configureWith(FakeCheckable(), checked: customOdrChecked, singleSelection: false)
            customOdrCheckBoxRow.addCompletion { result in
                self.customOdrChecked = result
                self.configureOrd(sensor, with: powerMode)
                return
            }

            customOdrTextField.configure { text in
                guard let text = text else { return }
                sensor.configuration?.oneShotTime = self.customOdrTextField.validate().boolValue() ? Int(text) : nil
            }
            customOdrTextField.titleText = nil
            customOdrTextField.placeholder = "odr_custom_value".localized()
            customOdrTextField.keyboardType = .decimalPad
            customOdrTextField.addDoneButtonToKeyboard()
            customOdrTextField.validators = [
                MinValueValidator(with: minCustomOdr, errorMessage: "error_field_odr_min_value".localized())
            ]
            customOdrMinLabel.text = "\("odr_min_value".localized()) \(minCustomOdr) \("um_second".localized())" //
        } else {
            customOdrStackView.isHidden = true
        }

        odrPicker.active = !customOdrChecked
        customOdrTextField.isEnabled = customOdrChecked
        customOdrTextField.text = customOdrChecked ? "\(sensor.configuration?.oneShotTime ?? powerMode.minCustomOdr ?? 0)" : nil
        
        if !customOdrChecked {
            customOdrTextField.isValid = true
            sensor.configuration?.oneShotTime = nil
        }
        
        self.configureFilters(sensor, with: powerMode, selectedOdr: odrPickerSelected)
    }
}
