//
//  PnpLContent+ViewModel.swift
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
import STUI
import STCore

public enum PnpLContentAction {
    case showCommandPicker(CodeValue<PickerInput>)
    case showPicker(CodeValue<ActionPickerInput>)
    case updateValue(CodeValue<TextInput>)
    case valueChanged(CodeValue<SwitchInput>)
    case emptyAction(CodeValue<ActionInput>)
    case textAction(CodeValue<ActionTextInput>)
    case loadFile(CodeValue<ActionInput>)
}

public extension Layout {
    static var standard: Layout = Layout(mainColor: ColorLayout.accent,
                                         textLayout: TextLayout.text.weight(.light).size(16.0),
                                         titleLayout: TextLayout.subtitle.weight(.bold),
                                         buttonLayout: Buttonlayout.text,
                                         margin: .standard)
    
    static var standardCenterSecondary: Layout = Layout(mainColor: ColorLayout.accent,
                                        textLayout: TextLayout.text.weight(.medium).size(18.0).alignment(.center).color(ColorLayout.secondary.auto),
                                        titleLayout: TextLayout.subtitle.weight(.bold),
                                        buttonLayout: Buttonlayout.text,
                                        margin: .standard)

    static var disabled: Layout = Layout(mainColor: ColorLayout.accent,
                                         textLayout: TextLayout.text.color(.lightGray).weight(.light).size(16.0),
                                         titleLayout: TextLayout.subtitle.weight(.bold),
                                         buttonLayout: Buttonlayout.text)
    
    static var title: Layout = Layout(mainColor: ColorLayout.accent,
                                         textLayout: TextLayout.title,
                                         titleLayout: TextLayout.subtitle.weight(.bold),
                                         buttonLayout: Buttonlayout.text,
                                         margin: .standard)
    
    static var title2: Layout = Layout(mainColor: ColorLayout.accent,
                                         textLayout: TextLayout.title2,
                                         titleLayout: TextLayout.subtitle.weight(.bold),
                                         buttonLayout: Buttonlayout.text,
                                         margin: .standard)
    
    static var infoBold: Layout = Layout(mainColor: ColorLayout.accent,
                                         textLayout: TextLayout.infoBold,
                                         titleLayout: TextLayout.subtitle.weight(.bold),
                                         buttonLayout: Buttonlayout.text,
                                         margin: .standard)
    
    static var info: Layout = Layout(mainColor: ColorLayout.accent,
                                         textLayout: TextLayout.info,
                                         titleLayout: TextLayout.subtitle.weight(.bold),
                                         buttonLayout: Buttonlayout.text,
                                         margin: .standard)
    
    static var standardButton: Layout = Layout(textLayout: TextLayout.text.size(16.0),
                                               titleLayout: TextLayout.subtitle.weight(.bold),
                                               buttonLayout: Buttonlayout.standard,
                                               margin: .standard)
    
    
//    static var blue: Layout = Layout(mainColor: ColorLayout.accent,
//                                     backgroundColor: ColorLayout.secondary,
//                                     textLayout: TextLayout.text.color(.black).weight(.light),
//                                     titleLayout: TextLayout.subtitle.weight(.bold),
//                                     buttonLayout: Buttonlayout.text,
//                                     margin: .standard)

    func text(textLayout: TextLayout?) -> Layout {
        Layout(mainColor: mainColor,
               backgroundColor: backgroundColor,
               textLayout: textLayout,
               titleLayout: titleLayout,
               buttonLayout: buttonLayout,
               margin: margin)
    }

    func backgroundColor(backgroundColor: Colorable?) -> Layout {
        Layout(mainColor: mainColor,
               backgroundColor: backgroundColor,
               textLayout: textLayout,
               titleLayout: titleLayout,
               buttonLayout: buttonLayout,
               margin: margin)
    }

    func buttonLayout(buttonLayout: Buttonlayout?) -> Layout {
        Layout(mainColor: mainColor,
               backgroundColor: backgroundColor,
               textLayout: textLayout,
               titleLayout: titleLayout,
               buttonLayout: buttonLayout,
               margin: margin)
    }
}

extension PnpLContent {

    public static var layout: Layout = Layout(mainColor: ColorLayout.primary,
                                       textLayout: TextLayout.text.weight(.light).size(14.0),
                                       titleLayout: TextLayout.subtitle.weight(.bold),
                                       buttonLayout: Buttonlayout.text)

    public func viewModels(with key: [String],
                           name: String?,
                           writable: Bool? = nil,
                           action: @escaping (PnpLContentAction) -> Void ) -> [any ViewModel] {

        var keys = key

        switch self {
        case .component(let pnpLComponentContent):
            return [
                ImageDetailViewModel(param: CodeValue<ImageDetail>(keys: keys,
                                                                   value: ImageDetail(title: pnpLComponentContent.compoundName,
                                                                                      subtitle: pnpLComponentContent.compoundSubtile,
                                                                                      image: pnpLComponentContent.icon)),
                                     layout: PnpLContent.layout)
                ]
        case .property(let pnpLPropertyContent):
            keys.append(pnpLPropertyContent.name)
            return pnpLPropertyContent.schema.viewModels(with: keys,
                                                         name: pnpLPropertyContent.displayName?.en,
                                                         writable: pnpLPropertyContent.writable,
                                                         action: action)
        case .primitiveProperty(let pnpLPrimitiveContent):

            keys.append(pnpLPrimitiveContent.name)
            if case .boolean = pnpLPrimitiveContent.schema {

                return [ SwitchViewModel(param: CodeValue<SwitchInput>(keys: keys,
                                                                       value: SwitchInput(title: pnpLPrimitiveContent.displayName?.en,
                                                                                           value: false,
                                                                                         isEnabled: pnpLPrimitiveContent.writable ?? false,
                                                                                           handleValueChanged: { value in
                    action(.valueChanged(value))
                })), layout: PnpLContent.layout) ]
            }

            return [ TextInputViewModel(param: CodeValue<TextInput>(keys: keys,
                                                                    value: TextInput(title: pnpLPrimitiveContent.displayName?.en,
                                                                                     isEnabled: pnpLPrimitiveContent.writable ?? false,
                                                                                     handleChangeText: { value in
                action(.updateValue(value))
            })), layout: PnpLContent.layout) ]
        case .enumerative(let pnpLEnumerativeContent):
            let values = pnpLEnumerativeContent.values.compactMap { value in
                return BoxedValue.object(value)
            }

            return [ PickerViewViewModel(param: CodeValue<PickerInput>(keys: keys,
                                                                       value: PickerInput(title: name,
                                                                                          selection: nil,
                                                                                          options: values,
                                                                                          isEnabled: true)),
                                         layout: PnpLContent.layout,
                                         handleSelectionTouched: { value in
                action(.showCommandPicker(value))
            }) ]
        case .object(let pnpLObjectContent):
            return [ ObjectViewModel(param: name,
                                     layout: PnpLContent.layout,
                                     childrenViewModels: pnpLObjectContent.fields.compactMap { field in

                let overrideWriteble = field.name.lowercased() == "min" || field.name.lowercased() == "max"
                let isEnabled = overrideWriteble ? false : ((pnpLObjectContent.writable != nil ? pnpLObjectContent.writable : writable) ?? false)

                var fieldKeys = keys
                fieldKeys.append(field.name)

                if case .boolean = field.schema {

                    return  SwitchViewModel(param: CodeValue<SwitchInput>(keys: fieldKeys,
                                                                          value: SwitchInput(title: field.displayName?.en,
                                                                                               value: false,
                                                                                               isEnabled: isEnabled,
                                                                                               handleValueChanged: { value in
                        action(.valueChanged(value))
                    })), layout: PnpLContent.layout)
                }

                return  TextInputViewModel(param: CodeValue<TextInput>(keys: fieldKeys,
                                                                        value: TextInput(title: field.displayName?.en,
                                                                                         isEnabled: isEnabled,
                                                                                         handleChangeText: { value in
                    action(.updateValue(value))

                })), layout: PnpLContent.layout)
            }) ]
        case .command(let pnpLCommandContent):

            var commandKeys = keys

            commandKeys.append(pnpLCommandContent.name)

            if pnpLCommandContent.name == "load_file" {
                return [ ActionViewModel(param: CodeValue<ActionInput>(keys: commandKeys,
                                                                       value: ActionInput(title: Localizer.Pnpl.Text.loadConfiguration.localized,
                                                                                          actionTitle: Localizer.Pnpl.Action.uploadFile.localized)),
                                         layout: PnpLContent.layout,
                                         handleButtonTouched: { value in
                    action(.loadFile(value))
                }) ]
            }

            if let request = pnpLCommandContent.request {
                switch request.schema {

                case .object(let object):
                    switch object {
                    case .enumerative(let pnpLEnumerativeContent):

                        let values = pnpLEnumerativeContent.values.compactMap { value in
                            return BoxedValue.object(value)
                        }

                        return [ ActionPickerViewModel(param: CodeValue<ActionPickerInput>(keys: commandKeys,
                                                                                           value: ActionPickerInput(title: name,
                                                                                                                    actionTitle: Localizer.Pnpl.Action.send.localized,
                                                                                                                    options: values)),
                                                       layout: PnpLContent.layout,
                                                       handleSelectionTouched: { value in

                            action(.showPicker(value))
                        },
                                                       handleButtonTouched: { value in

                        }) ]
                    default:
                        return [ LabelViewModel(param: CodeValue<String>(keys: [ UUID().uuidString ], value: "unknown"),
                                                layout: PnpLContent.layout) ]
                    }
                case .string:
                    commandKeys.append(request.name)
                    return [ ActionTextViewModel(param: CodeValue<ActionTextInput>(keys: commandKeys,
                                                                                   value: ActionTextInput(title: pnpLCommandContent.displayName?.en,
                                                                                                  actionTitle: Localizer.Pnpl.Action.send.localized,
                                                                                              handleButtonTouched: { value in
                        action(.textAction(value))
                    })), layout: PnpLContent.layout) ]
                }
            }

            return [ ActionViewModel(param: CodeValue<ActionInput>(keys: commandKeys,
                                                                   value: ActionInput(title: pnpLCommandContent.displayName?.en,
                                                                                      actionTitle: Localizer.Pnpl.Action.send.localized)),
                                     layout: PnpLContent.layout,
                                     handleButtonTouched: { value in
                action(.emptyAction(value))
            }) ]
            //        case .commandPayload(let pnpLCommandPayloadContent):
            //            <#code#>
            //        case .unknown(let pnpLUnknownContent):
//            <#code#>
        default:
            keys.append(UUID().uuidString)
            return [ LabelViewModel(param: CodeValue<String>(keys: keys, value: "unknown"), layout: PnpLContent.layout) ]

        }
    }
}
