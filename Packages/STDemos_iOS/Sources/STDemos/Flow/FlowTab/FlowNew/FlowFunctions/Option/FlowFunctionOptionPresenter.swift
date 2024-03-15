//
//  FlowFunctionOptionPresenter.swift
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

final class FlowFunctionOptionPresenter: BasePresenter<FlowFunctionOptionViewController, FunctionAndSensorParam> {

}

// MARK: - FlowFunctionOptionViewControllerDelegate
extension FlowFunctionOptionPresenter: FlowFunctionOptionDelegate {
    
    func load() {
        view.configureView()
        
        view.title = param.function.descr
        
        guard let properties = param.function.properties else { return }
        
        for (index, property) in properties.enumerated() {
            switch property.descriptor {
            case .bool:
                break
            case .float(let value):
                let desc = buildDescriptionString(property: property, isThresholdFun: param.function.isThreshold)
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
    
    func doneButtonTapped() {
        self.view.dismiss(animated: true)
    }
    
    func cancelButtonTapped() {
        self.view.dismiss(animated: true)
    }
}

extension FlowFunctionOptionPresenter {
    
    private func buildDescriptionString(property:Property, isThresholdFun:Bool)->String{
        guard let sensor = param.sensor else { return "" }

        switch(sensor.identifier){
        case "S1": return "Enter the temperature (in ℃) above which the threshold is triggered"
        case "S2": return "Enter the humidity (in %) above which the threshold is triggered"
        case "S3": return "Enter the pressure (in mbar) above which the threshold is triggered"
        case "S4": return "Enter the acceleration norm (in mg) above which the threshold is triggered"
        case "S5": return "Enter the acceleration norm (in mg) above which the threshold is triggered"
        case "S6": return "Enter the gyroscope norm (in mdps) above which the threshold is triggered"
        case "S7": return "Enter the acceleration norm (in mg) above which the threshold is triggered"
        case "S8": return "Enter the magnetometer norm (in mGa) above which the threshold is triggered"
        case "S10": return "Enter the time (in seconds) after which the threshold is triggered"
        default: return property.label
        }
    }
    
    func addTextField(_ index: Int, description: String, value: String) {
        let textField = TextField()
        textField.titleText = description
        textField.text = value
        textField.addDoneButtonToKeyboard()
        textField.configure { [weak self] text in
            guard let self = self, let text = text else { return }

            self.param.function.properties?[index].update(descriptor: Descriptior.string(value: text))
        }

        view.stackView.addArrangedSubview(textField.embedInView(with: UIEdgeInsets(top: 30.0, left: 0.0, bottom: 10.0, right: 0.0)))
    }
    
    func addTextField(_ index: Int, description: String, value: Int, min:Int?, max:Int?) {
        let textField = TextField()
        textField.titleText = description
        textField.text = String(value)
        textField.addDoneButtonToKeyboard()
        textField.keyboardType = .numberPad
        textField.configure { [weak self] text in
            guard let self = self, let text = Int(text ?? "") else { return }

            param.function.properties?[index].update(descriptor: Descriptior.intRange(value: text,min: nil,max: nil))
        }
        
        textField.validators = [ IntRangeValueValidator(min: min, max: max, errorMessage: "The entered value is not allowed")]
        
        view.stackView.addArrangedSubview(textField.embedInView(with: UIEdgeInsets(top: 30.0, left: 0.0, bottom: 10.0, right: 0.0)))
    }
    
    func addTextField(_ index: Int, description: String, value: Float) {
        let textField = TextField()
        textField.titleText = description
        textField.text = String(value)
        textField.addDoneButtonToKeyboard()
        textField.keyboardType = .decimalPad
        textField.configure { [weak self] text in
            guard let self = self, let text = Float(text ?? "") else { return }

            param.function.properties?[index].update(descriptor: Descriptior.float(value: text))
        }
        
        view.stackView.addArrangedSubview(textField.embedInView(with: UIEdgeInsets(top: 30.0, left: 0.0, bottom: 10.0, right: 0.0)))
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
            guard let self = self, let first = result.first, let radioValue = (first as? RadioValue) else { return }
                                
            self.param.function.properties?[index].update(descriptor: Descriptior.radio(values: values, selected: Int(radioValue.value)))
                                    
        }

        view.stackView.addArrangedSubview(checkBoxGroup)

    }

}
