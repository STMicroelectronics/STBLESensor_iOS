//
//  FunctionOptionsViewController.swift
//  trilobyte-lib-ios
//
//  Created by Marco De Lucchi on 24/04/2019.
//  Copyright © 2019 Codermine. All rights reserved.
//

import UIKit

class FunctionOptionsViewController: OptionsViewController<Function> {

    let textFieldEdgeInsets = UIEdgeInsets(top: 30.0, left: 0.0, bottom: 10.0, right: 0.0)

    private var mSensor:Sensor? = nil
    
    func configure(with item: Function, applayTo sensor:Sensor?) {
        super.configure(with: item)
        mSensor = sensor
    }
    
    override func configureView(with item: Function) {
        navigationItem.title = "function_options".localized()

        guard let properties = item.properties else { return }

        for (index, property) in properties.enumerated() {
            switch property.descriptor {
            case .bool:
                break
            case .float(let value):
                let desc = buildDescriptionString(property: property, isThresholdFun: item.isThreshold)
                addTextField(index, description:desc, value: value)
            case .intRange(let value, let min, let max):
                addTextField(index, description: property.label, value: value, min:min,max:max)
            case .radio(let values, let selected):
                addCheckBoxGroup(index, description: property.label, values: values, selected: selected)
            case .string(let value):
                addTextField(index, description: property.label, value: value)
            case .unsupported:
                break
            }
        }
    }
    
    private func buildDescriptionString(property:Property, isThresholdFun:Bool)->String{
        guard let sensor = mSensor, isThresholdFun else{
            return property.label
        }
        switch(sensor.identifier){
        case "S1": return "thresholdDesc_temperature".localized()
        case "S2": return "thresholdDesc_humidity".localized()
        case "S3": return "thresholdDesc_pressure".localized()
        case "S4": return "thresholdDesc_acceleration".localized()
        case "S5": return "thresholdDesc_acceleration".localized()
        case "S6": return "thresholdDesc_gyroscope".localized()
        case "S7": return "thresholdDesc_acceleration".localized()
        case "S8": return "thresholdDesc_magnetometer".localized()
        case "S10": return "thresholdDesc_timer".localized()
        default: return property.label
        }
    }
    
}

private extension FunctionOptionsViewController {

    func addTextField(_ index: Int, description: String, value: String) {
        let textField = TextField()
        textField.titleText = description
        textField.text = value
        textField.addDoneButtonToKeyboard()
        textField.configure { [weak self] text in
            guard let self = self, let text = text else { return }

            self.item?.properties?[index].update(descriptor: Descriptior.string(value: text))
        }

        stackView.addArrangedSubview(textField.embedInView(with: textFieldEdgeInsets))
    }

    func addTextField(_ index: Int, description: String, value: Int, min:Int?, max:Int?) {
        let textField = TextField()
        textField.titleText = description
        textField.text = String(value)
        textField.addDoneButtonToKeyboard()
        textField.keyboardType = .numberPad
        textField.configure { [weak self] text in
            guard let self = self, let text = Int(text ?? "") else { return }

            self.item?.properties?[index].update(descriptor: Descriptior.intRange(value: text,min: nil,max: nil))
        }
        
        textField.validators = [ IntRangeValueValidator(min: min, max: max, errorMessage: "err_value_not_allowed".localized())]
        
        stackView.addArrangedSubview(textField.embedInView(with: textFieldEdgeInsets))
    }

    func addTextField(_ index: Int, description: String, value: Float) {
        let textField = TextField()
        textField.titleText = description
        textField.text = String(value)
        textField.addDoneButtonToKeyboard()
        textField.keyboardType = .decimalPad
        textField.configure { [weak self] text in
            guard let self = self, let text = Float(text ?? "") else { return }

            self.item?.properties?[index].update(descriptor: Descriptior.float(value: text))
        }

        stackView.addArrangedSubview(textField.embedInView(with: textFieldEdgeInsets))
    }

    func addCheckBoxGroup(_ index: Int, description: String, values: [RadioValue], selected: Int) {
        let checkBoxGroup: CheckBoxGroup = CheckBoxGroup.createFromNib()

        var selectedValues = [Checkable]()
        if let first = values.first(where: { $0.value == selected }) {
            selectedValues.append(first)
        }

        checkBoxGroup.configure(title: description,
                                items: values,
                                selectedItems: selectedValues,
                                singleSelection: true) { [weak self] result in
                                    guard let self = self, let first = result.first, let value = Int(first.descr) else { return }
                                
                                    self.item?.properties?[index].update(descriptor: Descriptior.radio(values: values, selected: value))
                                    
        }

        stackView.addArrangedSubview(checkBoxGroup)

    }
}
