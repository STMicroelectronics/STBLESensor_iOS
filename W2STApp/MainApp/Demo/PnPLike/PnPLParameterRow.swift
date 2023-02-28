//
//  PnPLEnumRow.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import BlueSTSDK
import UIKit

public class PnPLParameterRow {
    
    // MARK: - Select which type of row to build
    public static func buildParameterRow(
        cellIndex: Int,
        paramIndex: Int,
        param: PnPLConfigurationParameter,
        target: Any?,
        btnAction: Selector,
        textFieldAction: Selector,
        switchAction: Selector,
        btnSENDAction: Selector,
        btnLOADFILEAction: Selector,
        dismissKeyboard: Selector
    ) -> UIStackView {
        
        switch param.type {
            
            case .PropertyStandard:
                return buildStandardParameterRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    param: param,
                    target: target,
                    btnAction: btnAction,
                    textFieldAction: textFieldAction,
                    switchAction: switchAction
                )
            case .PropertyEnumeration:
                return buildEnumerationParameterRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    param: param,
                    target: target,
                    btnAction: btnAction,
                    textFieldAction: textFieldAction
                )
            case .PropertyObject:
                return buildObjectParameterRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    param: param,
                    target: target,
                    btnAction: btnAction,
                    textFieldAction: textFieldAction,
                    switchAction: switchAction
                )
            case .CommandEmpty:
                return buildEmptyCommandRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    param: param,
                    target: target,
                    btnSENDAction: btnSENDAction
                )
            case .CommandStandard:
                return buildStandardCommandRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    param: param,
                    target: target,
                    textFieldAction: textFieldAction,
                    btnSENDAction: btnSENDAction,
                    dismissKeyboard: dismissKeyboard
                )
            case .CommandEnumeration:
                return buildEnumerationCommandRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    param: param,
                    target: target,
                    textFieldAction: textFieldAction,
                    switchAction: switchAction,
                    btnSENDAction: btnSENDAction,
                    btnAction: btnAction
                )
            case .CommandObject:
                return buildObjectCommandRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    param: param,
                    target: target,
                    textFieldAction: textFieldAction,
                    switchAction: switchAction,
                    btnSENDAction: btnSENDAction,
                    btnLOADFILEAction: btnLOADFILEAction,
                    dismissKeyboard: dismissKeyboard
                )
            case .none:
                return buildEmptyRow()
        }
        
    }
    
    // MARK: - Build EMPTY Row
    public static func buildEmptyRow() -> UIStackView {
        let name = UILabel()
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            name
        ])
        return horizontalSV
    }

// MARK: - PROPERTIES
    
    // MARK: - Build STANDARD Row
    public static func buildStandardParameterRow(
        cellIndex: Int,
        paramIndex: Int,
        param: PnPLConfigurationParameter,
        target: Any?,
        btnAction: Selector,
        textFieldAction: Selector,
        switchAction: Selector
    ) -> UIStackView {
        
        let name = UILabel()
        let value = PnPLCustomTextField()
        let valueBoolean = PnPLCustomSwicth()
        
        /// Set visible Switch Only when necessary
        valueBoolean.isHidden = true
        
        /// UILabel used for display parameter NAME
        name.text = param.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        if(param.detail?.primitiveType == "boolean"){
            /// UISwitch if boolean value is present
            if(param.detail != nil){
                if(param.detail?.currentValue != nil){
                    valueBoolean.isHidden = false
                    valueBoolean.clearsContextBeforeDrawing = true
                    valueBoolean.setContentHuggingPriority(UILayoutPriority(rawValue: 998), for: .horizontal)
                    if("\(param.detail!.currentValue!)" == "true"){
                        valueBoolean.isOn = true
                    } else {
                        valueBoolean.isOn = false
                    }
                    valueBoolean.addTarget(target, action: switchAction, for: .valueChanged)
                    valueBoolean.cellIndex = cellIndex
                    valueBoolean.paramIndex = paramIndex
                }
            }
        } else {
            /// UITextField [PnPLCustomTextField] used for handle parameter VALUE
            value.text = "\(param.detail?.currentValue ?? " ")"
            value.font = UIFont.boldSystemFont(ofSize: 11)
            value.clearsContextBeforeDrawing = true
            value.setContentHuggingPriority(UILayoutPriority(rawValue: 997), for: .horizontal)
            
            value.borderStyle = UITextField.BorderStyle.roundedRect
            value.autocorrectionType = UITextAutocorrectionType.no
            value.keyboardType = UIKeyboardType.default
            value.returnKeyType = UIReturnKeyType.done
            value.clearButtonMode = UITextField.ViewMode.whileEditing;
            
            value.addTarget(target, action: textFieldAction, for: .editingDidEndOnExit)
            value.param = param
            value.cellIndex = cellIndex
            value.paramIndex = paramIndex
        }
        
        /// If NOT writable show in gray color & disable User Interactions
        if(param.writable == false){
            name.textColor = .gray
            value.textColor = .gray
            value.isUserInteractionEnabled = false
            valueBoolean.isUserInteractionEnabled = false
            valueBoolean.isEnabled = false
        }
        
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            name,
            valueBoolean,
            value
        ])
        
        return horizontalSV
    
    }
    
    // MARK: - Build ENUMERATION Row
    public static func buildEnumerationParameterRow(
        cellIndex: Int,
        paramIndex: Int,
        param: PnPLConfigurationParameter,
        target: Any?,
        btnAction: Selector,
        textFieldAction: Selector
    ) -> UIStackView {
        
        let name = UILabel()
        let value = PnPLCustomTextField()
        let enumBtn = PnPLCustomButton()
        
        /// UILabel used for display parameter NAME
        name.text = param.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        if(param.detail?.enumValues?.count ?? 0 > 0){
            
            /// UILabel used for display parameter VALUE in case there is an Enumeration
            if(param.detail?.currentValue != nil){
                value.text = param.detail?.enumValues![param.detail?.currentValue! as! Int]
                value.clearsContextBeforeDrawing = true
                value.setContentHuggingPriority(UILayoutPriority(rawValue: 997), for: .horizontal)
                value.isUserInteractionEnabled = false
            } else {
                value.text = param.detail?.enumValues![0]
            }
            
            /// PnPLCustomButton [PnPLCustomButton] definition
            enumBtn.setTitle(" ", for: .normal)
            enumBtn.setImage(UIImage(named: "ic_arrow_down_filled"), for: .normal)
            enumBtn.contentHorizontalAlignment = .right
            enumBtn.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
            
            enumBtn.addTarget(target, action: btnAction, for: .touchUpInside)
            enumBtn.param = param
            enumBtn.cellIndex = cellIndex
            enumBtn.paramIndex = paramIndex
            
        }
        
        /// If NOT writable show in gray color & disable User Interactions
        if(param.writable == false){
            name.textColor = .gray
            value.textColor = .gray
            value.isUserInteractionEnabled = false
            enumBtn.isUserInteractionEnabled = false
            enumBtn.isEnabled = false
        }
        
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            name,
            value,
            enumBtn
        ])
        
        return horizontalSV
    
    }
    
    // MARK: - Build OBJECT Row
    public static func buildObjectParameterRow(
        cellIndex: Int,
        paramIndex: Int,
        param: PnPLConfigurationParameter,
        target: Any?,
        btnAction: Selector,
        textFieldAction: Selector,
        switchAction: Selector
    ) -> UIStackView {
        
        let name = UILabel()
        
        /// UILabel used for display parameter NAME
        name.text = param.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        var j=0
        var objRows: [UIStackView] = []
        
        param.detail?.paramObj?.forEach{ obj in
            objRows.append(
                buildSingleObjectParameterRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    objectIndex: j,
                    object: obj,
                    target: target,
                    btnAction: btnAction,
                    textFieldAction: textFieldAction,
                    switchAction: switchAction
                )
            )
            j+=1
        }
        
        var verticalSV = UIStackView()
        verticalSV = UIStackView.getVerticalStackView(withSpacing: 8, views: objRows)
        verticalSV.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        verticalSV.isLayoutMarginsRelativeArrangement = true
        
        var complexSV = UIStackView()
        complexSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            name,
            verticalSV
        ])
        complexSV.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        complexSV.isLayoutMarginsRelativeArrangement = true
        
        return complexSV
    
    }
    
    public static func buildSingleObjectParameterRow(
        cellIndex: Int,
        paramIndex: Int,
        objectIndex: Int,
        object: ObjectNameValue,
        target: Any?,
        btnAction: Selector,
        textFieldAction: Selector,
        switchAction: Selector
    ) -> UIStackView {
        
        let name = UILabel()
        let value = PnPLCustomTextField()
        let valueBoolean = PnPLCustomSwicth()
        
        /// Set visible Switch Only when necessary
        valueBoolean.isHidden = true
        
        /// UILabel used for display parameter NAME
        name.text = object.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        if(object.primitiveType == "boolean"){
            /// UISwitch if boolean value is present
            if(object.currentValue != nil){
                valueBoolean.isHidden = false
                valueBoolean.clearsContextBeforeDrawing = true
                valueBoolean.setContentHuggingPriority(UILayoutPriority(rawValue: 998), for: .horizontal)
                if("\(object.currentValue!)" == "true"){
                    valueBoolean.isOn = true
                } else {
                    valueBoolean.isOn = false
                }
                valueBoolean.addTarget(target, action: switchAction, for: .valueChanged)
                //valueBoolean.param = param
                valueBoolean.cellIndex = cellIndex
                valueBoolean.paramIndex = paramIndex
                valueBoolean.objectIndex = objectIndex
            }
        } else {
            /// UITextField [PnPLCustomTextField] used for handle parameter VALUE
            value.text = "\(object.currentValue ?? " ")"
            value.font = UIFont.boldSystemFont(ofSize: 11)
            value.clearsContextBeforeDrawing = true
            value.setContentHuggingPriority(UILayoutPriority(rawValue: 997), for: .horizontal)
            
            value.borderStyle = UITextField.BorderStyle.roundedRect
            value.autocorrectionType = UITextAutocorrectionType.no
            value.keyboardType = UIKeyboardType.default
            value.returnKeyType = UIReturnKeyType.done
            value.clearButtonMode = UITextField.ViewMode.whileEditing;
            
            value.addTarget(target, action: textFieldAction, for: .editingDidEndOnExit)
            value.cellIndex = cellIndex
            value.paramIndex = paramIndex
            value.objectIndex = objectIndex
        }
        
        /// If it is MIN / MAX parameter, disable user interactions
        if(object.name == "min" || object.name == "max"){
            name.textColor = .gray
            value.textColor = .gray
            value.isUserInteractionEnabled = false
            valueBoolean.isUserInteractionEnabled = false
            valueBoolean.isEnabled = false
        }
        
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            name,
            valueBoolean,
            value
        ])
        
        return horizontalSV
    
    }
    
    
// MARK: - COMMANDS
    
    // MARK: - Build Empty Command Row
    public static func buildEmptyCommandRow(
        cellIndex: Int,
        paramIndex: Int,
        param: PnPLConfigurationParameter,
        target: Any?,
        btnSENDAction: Selector
    ) -> UIStackView {
        
        let name = UILabel()
        let sendBtn = PnPLSENDCustomButton()
        
        /// UILabel used for display parameter NAME
        name.text = param.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        
        sendBtn.setTitle("SEND", for: .normal)
        sendBtn.clearsContextBeforeDrawing = true
        sendBtn.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        sendBtn.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        sendBtn.addTarget(target, action: btnSENDAction, for: .touchUpInside)
        sendBtn.cellIndex = cellIndex
        sendBtn.paramIndex = paramIndex
        
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            name,
            sendBtn
        ])
        
        return horizontalSV
    }
    
    // MARK: - Build Standard Command Row
    public static func buildStandardCommandRow(
        cellIndex: Int,
        paramIndex: Int,
        param: PnPLConfigurationParameter,
        target: Any?,
        textFieldAction: Selector,
        btnSENDAction: Selector,
        dismissKeyboard: Selector
    ) -> UIStackView {
        
        let name = UILabel()
        let value = PnPLCustomTextField()
        let sendBtn = PnPLSENDCustomButton()
        
        /// UILabel used for display parameter NAME
        name.text = param.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
        
        /// UITextField [PnPLCustomTextField] used for handle parameter VALUE
        value.text = "\(param.detail?.currentValue ?? " ")"
        value.font = UIFont.boldSystemFont(ofSize: 11)
        value.clearsContextBeforeDrawing = true
        value.setContentHuggingPriority(UILayoutPriority(rawValue: 997), for: .horizontal)
        
        value.borderStyle = UITextField.BorderStyle.roundedRect
        value.autocorrectionType = UITextAutocorrectionType.no
        value.keyboardType = UIKeyboardType.default
        value.returnKeyType = UIReturnKeyType.done
        value.clearButtonMode = UITextField.ViewMode.whileEditing;
        
        value.addTarget(target, action: dismissKeyboard, for: .editingDidEndOnExit)
        value.param = param
        value.cellIndex = cellIndex
        value.paramIndex = paramIndex
        
        sendBtn.setTitle("SEND", for: .normal)
        sendBtn.clearsContextBeforeDrawing = true
        sendBtn.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        sendBtn.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        sendBtn.addTarget(target, action: btnSENDAction, for: .touchUpInside)
        sendBtn.cellIndex = cellIndex
        sendBtn.paramIndex = paramIndex
        sendBtn.value = []
        sendBtn.value?.append(value)
        
        /// If NOT writable show in gray color & disable User Interactions
        if(param.writable == false){
            name.textColor = .gray
            value.textColor = .gray
            value.isUserInteractionEnabled = false
        }
        
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            name,
            value,
            sendBtn
        ])
        
        return horizontalSV
    }
    
    // MARK: - Build OBJECT Command Row
    public static func buildEnumerationCommandRow(
        cellIndex: Int,
        paramIndex: Int,
        param: PnPLConfigurationParameter,
        target: Any?,
        textFieldAction: Selector,
        switchAction: Selector,
        btnSENDAction: Selector,
        btnAction: Selector
    ) -> UIStackView {
        
        let name = UILabel()
        let value = PnPLCustomTextField()
        let enumBtn = PnPLCustomButton()
        let sendBtn = PnPLSENDCustomButton()
        
        /// UILabel used for display parameter NAME
        name.text = param.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        sendBtn.setTitle("SEND", for: .normal)
        sendBtn.clearsContextBeforeDrawing = true
        sendBtn.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        sendBtn.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        sendBtn.addTarget(target, action: btnSENDAction, for: .touchUpInside)
        sendBtn.cellIndex = cellIndex
        sendBtn.paramIndex = paramIndex
        
        if(param.detail?.enumValues?.count ?? 0 > 0){
            
            /// UILabel used for display parameter VALUE in case there is an Enumeration
            if(param.detail?.currentValue != nil){
                value.text = param.detail?.enumValues![param.detail?.currentValue! as! Int]
                value.clearsContextBeforeDrawing = true
                value.setContentHuggingPriority(UILayoutPriority(rawValue: 997), for: .horizontal)
                value.isUserInteractionEnabled = false
            } else {
                value.text = param.detail?.enumValues![0]
            }
            
            sendBtn.value = []
            sendBtn.value?.append(value)
            
            /// PnPLCustomButton [PnPLCustomButton] definition
            enumBtn.setTitle(" ", for: .normal)
            enumBtn.setImage(UIImage(named: "ic_arrow_down_filled"), for: .normal)
            enumBtn.contentHorizontalAlignment = .right
            enumBtn.setContentHuggingPriority(UILayoutPriority(rawValue: 999), for: .horizontal)
            
            enumBtn.addTarget(target, action: btnAction, for: .touchUpInside)
            enumBtn.param = param
            enumBtn.cellIndex = cellIndex
            enumBtn.paramIndex = paramIndex
            
            sendBtn.enumValues = [:]
            sendBtn.enumValues = param.detail?.enumValues
        }
        
        /// If NOT writable show in gray color & disable User Interactions
        if(param.writable == false){
            name.textColor = .gray
            value.textColor = .gray
            value.isUserInteractionEnabled = false
            enumBtn.isUserInteractionEnabled = false
            enumBtn.isEnabled = false
        }
        
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            name,
            value,
            enumBtn,
            sendBtn
        ])
        
        return horizontalSV
    }
    
    // MARK: - Build OBJECT Command Row
    public static func buildObjectCommandRow(
        cellIndex: Int,
        paramIndex: Int,
        param: PnPLConfigurationParameter,
        target: Any?,
        textFieldAction: Selector,
        switchAction: Selector,
        btnSENDAction: Selector,
        btnLOADFILEAction: Selector,
        dismissKeyboard: Selector
    ) -> UIStackView {
        
        /** Used to build Button Loading UCF File */
        if(param.name == "load_file"){
            let name = UILabel()
            let uploadFileButton = PnPLUploadFileCustomButton()
            /// UILabel used for display parameter NAME
            name.text = param.displayName
            name.font = UIFont.boldSystemFont(ofSize: 11)
            name.clearsContextBeforeDrawing = true
            name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
            name.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
            
            uploadFileButton.setTitle("UPLOAD FILE", for: .normal)
            uploadFileButton.clearsContextBeforeDrawing = true
            uploadFileButton.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .horizontal)
            uploadFileButton.setContentHuggingPriority(UILayoutPriority(rawValue: 998), for: .horizontal)
            uploadFileButton.addTarget(target, action: btnLOADFILEAction, for: .touchUpInside)
            uploadFileButton.cellIndex = cellIndex
            uploadFileButton.paramIndex = paramIndex
            uploadFileButton.paramsName = []
            param.detail?.paramObj?.forEach{ obj in
                uploadFileButton.paramsName?.append(obj.name ?? " ")
            }
            
            var sv = UIStackView()
            sv = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
                name,
                uploadFileButton
            ])
            
            return sv
        }
        
        let name = UILabel()
        let sendBtn = PnPLSENDCustomButton()
        
        /// UILabel used for display parameter NAME
        name.text = param.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        sendBtn.setTitle("SEND", for: .normal)
        sendBtn.clearsContextBeforeDrawing = true
        sendBtn.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998), for: .horizontal)
        sendBtn.setContentHuggingPriority(UILayoutPriority(rawValue: 998), for: .horizontal)
        sendBtn.addTarget(target, action: btnSENDAction, for: .touchUpInside)
        sendBtn.cellIndex = cellIndex
        sendBtn.paramIndex = paramIndex
        sendBtn.value = []
        
        var j=0
        var objRows: [UIStackView] = []
        
        param.detail?.paramObj?.forEach{ obj in
            objRows.append(
                buildSingleObjectCommandRow(
                    cellIndex: cellIndex,
                    paramIndex: paramIndex,
                    objectIndex: j,
                    object: obj,
                    target: target,
                    btnAction: btnSENDAction,
                    textFieldAction: textFieldAction,
                    switchAction: switchAction,
                    dismissKeyboard: dismissKeyboard,
                    sendBtn: sendBtn
                )
            )
            j+=1
        }
        
        var verticalSV = UIStackView()
        verticalSV = UIStackView.getVerticalStackView(withSpacing: 8, views: objRows)
        verticalSV.layoutMargins = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 0)
        verticalSV.isLayoutMarginsRelativeArrangement = true
        
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            verticalSV,
            sendBtn
        ])
        
        var complexSV = UIStackView()
        complexSV = UIStackView.getVerticalStackView(withSpacing: 8, views: [
            name,
            horizontalSV
        ])
        complexSV.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        complexSV.isLayoutMarginsRelativeArrangement = true
        
        return complexSV
    }
    
    public static func buildSingleObjectCommandRow(
        cellIndex: Int,
        paramIndex: Int,
        objectIndex: Int,
        object: ObjectNameValue,
        target: Any?,
        btnAction: Selector,
        textFieldAction: Selector,
        switchAction: Selector,
        dismissKeyboard: Selector,
        sendBtn: PnPLSENDCustomButton
    ) -> UIStackView {
        
        let name = UILabel()
        let value = PnPLCustomTextField()
        let valueBoolean = PnPLCustomSwicth()
        
        /// Set visible Switch Only when necessary
        valueBoolean.isHidden = true
        
        /// UILabel used for display parameter NAME
        name.text = object.displayName
        name.font = UIFont.boldSystemFont(ofSize: 11)
        name.clearsContextBeforeDrawing = true
        name.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        name.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        if(object.primitiveType == "boolean"){
            /// UISwitch if boolean value is present
            if(object.currentValue != nil){
                valueBoolean.isHidden = false
                valueBoolean.clearsContextBeforeDrawing = true
                valueBoolean.setContentHuggingPriority(UILayoutPriority(rawValue: 996), for: .horizontal)
                if("\(object.currentValue!)" == "true"){
                    valueBoolean.isOn = true
                } else {
                    valueBoolean.isOn = false
                }
                //valueBoolean.addTarget(target, action: switchAction, for: .valueChanged)
                //valueBoolean.param = param
                valueBoolean.cellIndex = cellIndex
                valueBoolean.paramIndex = paramIndex
                valueBoolean.objectIndex = objectIndex
            }
        } else {
            /// UITextField [PnPLCustomTextField] used for handle parameter VALUE
            value.text = "\(object.currentValue ?? " ")"
            value.font = UIFont.boldSystemFont(ofSize: 11)
            value.clearsContextBeforeDrawing = true
            value.setContentHuggingPriority(UILayoutPriority(rawValue: 997), for: .horizontal)
            
            value.borderStyle = UITextField.BorderStyle.roundedRect
            value.autocorrectionType = UITextAutocorrectionType.no
            value.keyboardType = UIKeyboardType.default
            value.returnKeyType = UIReturnKeyType.done
            value.clearButtonMode = UITextField.ViewMode.whileEditing;
            
            value.addTarget(target, action: dismissKeyboard, for: .editingDidEndOnExit)
            value.cellIndex = cellIndex
            value.paramIndex = paramIndex
            value.objectIndex = objectIndex
        }
        
        sendBtn.value?.append(value)
        
        var horizontalSV = UIStackView()
        horizontalSV = UIStackView.getHorizontalStackView(withSpacing: 8, views: [
            name,
            valueBoolean,
            value
        ])
        
        return horizontalSV
    
    }

}

/** Customized Button for Enum Value Selection */
public class PnPLCustomButton : UIButton {
    var param : PnPLConfigurationParameter?
    var cellIndex: Int?
    var paramIndex: Int?
}

/** Customized TextField - handle set new value */
public class PnPLCustomTextField : UITextField {
    var param : PnPLConfigurationParameter?
    var cellIndex: Int?
    var paramIndex: Int?
    var objectIndex: Int?
}

/** Customized UISwitch - handle set new true/false value */
public class PnPLCustomSwicth : UISwitch {
    //var param : PnPLConfigurationParameter?
    var cellIndex: Int?
    var paramIndex: Int?
    var objectIndex: Int?
}

/** Customized Button for Enum Value Selection */
public class PnPLSENDCustomButton : UIButton {
    var cellIndex: Int?
    var paramIndex: Int?
    var objectIndex: Int?
    var value: [PnPLCustomTextField]?
    var enumValues: [Int : String]?
}

/** Customized Button for Enum Value Selection */
public class PnPLUploadFileCustomButton : UIButton {
    var cellIndex: Int?
    var paramIndex: Int?
    var objectIndex: Int?
    var paramsName: [String]?
}
