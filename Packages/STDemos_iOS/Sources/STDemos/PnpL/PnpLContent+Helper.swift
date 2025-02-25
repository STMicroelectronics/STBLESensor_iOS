//
//  PnpLContent+Helper.swift
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

public enum PnpLContentFilter {
    case sensors
    case rawPnPLControlled
    case motorControl
    case notSensors
    case all
}

extension PnpLContent {
    public var identifier: String? {
        switch self {
        case .interface(let content):
            return content.id

        default:
            return nil
        }
    }

    public var componentName: String? {
        switch self {
        case .interface(let content):
            return content.name
        case .component(let content):
            return content.name
        case .primitiveProperty(let content):
            return content.name
        case .property(let content):
            return content.name
        case .command(let content):
            return content.name

        default:
            return nil
        }
    }

    public var componentDisplayName: String? {
        switch self {
        case .component(let content):
            return content.compoundName
        case .property(let content):
            return content.displayName?.en ?? ""
        case .interface(let content):
            return content.displayName?.en ?? ""

        default:
            return nil
        }
    }

    public var componentSchema: String? {
        switch self {
        case .component(let content):
            return content.schema

        default:
            return nil
        }
    }
}

public extension Array where Element == PnpLContent {

    var rawPnPLControlled: [PnpLContent] {
        contents(with: [
            ContentFilter(component: .none,
                          filters: [ .plain(filter: "st_ble_stream"),
                                     .plain(filter: "fs")]),
        ], filter: .rawPnPLControlled) ?? []
    }
    
    var motorControl: [PnpLContent] {
        contents(with: [
            ContentFilter(component: .none,
                          filters: [ .plain(filter: "st_ble_stream"),
                                     .plain(filter: "fs"),
                                     .plain(filter: "odr"),
                                     .plain(filter: "aop"),
                                     .plain(filter: "enable"),
                                     .plain(filter: "load_file"),
                                     .plain(filter: "ucf_status"),
                                     .plain(filter: "name"),
                                     .plain(filter: "description"),
                                     .object(name: "sw_tag0", filters: [ "label", "enabled" ]),
                                     .object(name: "sw_tag1", filters: [ "label", "enabled" ]),
                                     .object(name: "sw_tag2", filters: [ "label", "enabled" ]),
                                     .object(name: "sw_tag3", filters: [ "label", "enabled" ]),
                                     .object(name: "sw_tag4", filters: [ "label", "enabled" ])
                          ]),
        ], filter: .motorControl) ?? []
    }
    
    var sensors: [PnpLContent] {
        contents(with: [
            ContentFilter(component: nil,
                          filters: [ .plain(filter: "fs"),
                                     .plain(filter: "odr"),
                                     .plain(filter: "aop"),
                                     .plain(filter: "enable"),
                                     .plain(filter: "mounted"),
                                     .plain(filter: "load_file"),
                                     .plain(filter: "ucf_status") ])
        ], filter: .sensors) ?? []
    }

    var automode: [PnpLContent] {
        contents(with: [
            ContentFilter(component: "automode",
                          filters: [])
        ], filter: .notSensors) ?? []
    }

    var settingsNotLogging: [PnpLContent] {

        let tags = contents(with: [
            ContentFilter(component: "tags_info", filters: [])
        ], filter: .notSensors) ?? []


        var tagContents: [PnpLContent] = []

        for tag in tags {
            if case .interface(let interface) = tag {
                for content in interface.contents {
                    if case .component(let component) = content {
                        if component.name == "tags_info" {
                            for tag in tags {
                                if case .interface(let interface) = tag {
                                    if interface.id == component.schema {

                                        tagContents.append(contentsOf: interface.contents)

                                        break
                                    }
                                }
                            }
                        }
                    }
                }

                break
            }
        }

        let tagsName = tagContents.compactMap {
            ($0.componentName != "max_tags_num" &&
             !($0.componentName?.contains("hw_tag") ?? false)) ? $0.componentName : nil
        }

        let tagsFilters = tagsName.map { ComponentFilter.object(name: $0, filters: [ "label", "enabled" ]) }

        return contents(with: [
            ContentFilter(component: "acquisition_info",
                          filters: [ .plain(filter: "name"),
                                     .plain(filter: "description") ]),

            ContentFilter(component: "tags_info",
                          filters: tagsFilters)
        ], filter: .notSensors) ?? []
    }

    var settingsLogging: [PnpLContent] {
        contents(with: [
            ContentFilter(component: "acquisition_info",
                          filters: [ .plain(filter: "name"),
                                     .plain(filter: "description") ]),

            ContentFilter(component: "tags_info",
                          filters: [
                            .object(name: "sw_tag0", filters: [ "label", "status" ]),
                            .object(name: "sw_tag1", filters: [ "label", "status" ]),
                            .object(name: "sw_tag2", filters: [ "label", "status" ]),
                            .object(name: "sw_tag3", filters: [ "label", "status" ]),
                            .object(name: "sw_tag4", filters: [ "label", "status" ]),
                            .object(name: "sw_tag5", filters: [ "label", "status" ]),
                            .object(name: "sw_tag6", filters: [ "label", "status" ]),
                            .object(name: "sw_tag7", filters: [ "label", "status" ]),
                            .object(name: "sw_tag8", filters: [ "label", "status" ]),
                            .object(name: "sw_tag9", filters: [ "label", "status" ]),
                            .object(name: "sw_tag10", filters: [ "label", "status" ]),
                            .object(name: "sw_tag11", filters: [ "label", "status" ]),
                            .object(name: "sw_tag12", filters: [ "label", "status" ]),
                            .object(name: "sw_tag13", filters: [ "label", "status" ]),
                            .object(name: "sw_tag14", filters: [ "label", "status" ]),
                            .object(name: "sw_tag15", filters: [ "label", "status" ]),
                            .object(name: "sw_tag16", filters: [ "label", "status" ])
                                   ])
        ], filter: .notSensors) ?? []
    }
    
    func filteredTags(activeTags: [String]) -> [PnpLContent] {
        var filters : [ComponentFilter] = []
        activeTags.forEach{ tag in
            filters.append(.object(name: tag, filters: [ "label", "status" ]))
        }
        
        return contents(with: [
            ContentFilter(component: "acquisition_info",
                          filters: [ .plain(filter: "name"),
                                     .plain(filter: "description") ]),
                
            ContentFilter(component: "tags_info",
                          filters: filters)
        ], filter: .notSensors) ?? []
    }

    func contents(with demo: Demo) -> [PnpLContent]? {

        guard case var .interface(interface) = first else {
            return []
        }

        var contents = [PnpLContent]()

        if case let .interface(applicationDescriptorInterface) = first(where: { content in
            if case let .interface(interface) = content {
                return interface.contents.first(where: { $0.componentName == "applications_stblesensor" }) != nil
            }
            return false
        }),
           case let .component(applicationComponent) = applicationDescriptorInterface.contents.first(where: { content in
               if case .component(_) = content {
                   return content.componentName == "applications_stblesensor"
               }
               return false
           }),
           case let .interface(applicationInterface) = first(where: { content in
               if case .interface(_) = content {
                   return content.identifier == applicationComponent.schema
               }
               return false
           }),
           case let .property(applicationProperty) = applicationInterface.contents.first(where: { content in
               return content.componentDisplayName == demo.title
           }),
           case let .object(schema) = applicationProperty.schema {

            let componentNames = schema.fields.compactMap { $0.name }

            let components = applicationDescriptorInterface.contents.filter({ content in
                return componentNames.contains(content.componentName ?? "")
            })

            contents.append(contentsOf: components)
        }

        var newContents = [PnpLContent]()

        let interfaceContents = contents.compactMap { content in
            if case let .component(componentContent) = interface.contents.first(where: { $0.componentName == content.componentName }) {
                return componentContent
            }
            return nil
        }

        interface.contents = interfaceContents.map { PnpLContent.component($0) }

        guard !contents.isEmpty else { return nil }
        
        newContents.append(.interface(interface))

        for content in contents {
            if case let .interface(interfaceContent) = first(where: { $0.identifier == content.componentSchema }) {
                newContents.append(.interface(interfaceContent))
            }
        }

        return newContents
    }

    func contents(with filters: [ContentFilter], filter: PnpLContentFilter) -> [PnpLContent]? {
        guard case var .interface(interface) = first else {
            return []
        }

        var newContents = [PnpLContent]()

        var filteredContents = [PnpLContent]()

        let componentNames = filters.compactMap { $0.component }

        switch filter {
        case .sensors:
            filteredContents.append(contentsOf: interface.contents.filter {
                (componentNames.count == 0 || componentNames.contains($0.componentName ?? "")) && $0.componentSchema?.contains("sensors") ?? false
            })
        case .rawPnPLControlled:
            filteredContents.append(contentsOf: interface.contents.filter {
                (componentNames.count == 0 || componentNames.contains($0.componentName ?? ""))
            })
        case .motorControl:
            filteredContents.append(contentsOf: interface.contents.filter {
                (componentNames.count == 0 || componentNames.contains($0.componentName ?? "")) && $0.componentSchema?.contains("slow_mc_telemetries") ?? false ||
                (componentNames.count == 0 || componentNames.contains($0.componentName ?? "")) && $0.componentSchema?.contains("fast_mc_telemetries") ?? false ||
                (componentNames.count == 0 || componentNames.contains($0.componentName ?? "")) && $0.componentSchema?.contains("sensors") ?? false ||
                (componentNames.count == 0 || componentNames.contains($0.componentName ?? "")) && $0.componentSchema?.contains("acquisition_info") ?? false ||
                (componentNames.count == 0 || componentNames.contains($0.componentName ?? "")) && $0.componentSchema?.contains("tags_info") ?? false
            })
        case .notSensors:
            filteredContents.append(contentsOf: interface.contents.filter {
                (componentNames.count == 0 || componentNames.contains($0.componentName ?? "")) &&
                !($0.componentSchema?.contains("sensors") ?? false)
            })
        case .all:
            filteredContents.append(contentsOf: interface.contents)
        }

        interface.contents = filteredContents

        newContents.append(.interface(interface))

        for content in filteredContents {
            if case var .interface(interfaceContent) = first(where: { $0.identifier == content.componentSchema }) {


                var fieldNames = filters.first(where: { $0.component == content.componentName }).map { $0.filters } ?? []

                let commonFieldNames = filters.first(where: { $0.component == nil }).map { $0.filters } ?? []

                fieldNames.append(contentsOf: commonFieldNames)

                let contents = interfaceContent.contents.compactMap { content in

                    if fieldNames.count == 0 {
                        return content
                    }

                    if let name = content.componentName?.lowercased(),
                       let filter = fieldNames.getFilter(with: name) {
                        if case .plain(_) = filter {
                            return content
                        } else if case .object(let name, let filters) = filter,
                                  case .property(var pnpLPropertyContent) = content,
                                  pnpLPropertyContent.name == name,
                                  case .object(var pnpLObjectContent) = pnpLPropertyContent.schema {

                            let fields = pnpLObjectContent.fields.compactMap { filters.contains($0.name) ? $0 : nil }
                            pnpLObjectContent.fields = fields
                            pnpLPropertyContent.schema = .object(pnpLObjectContent)

                            return .property(pnpLPropertyContent)
                        } else {
                            return nil
                        }
                    } else {
                        return nil
                    }
                }

                interfaceContent.contents = contents

                if contents.count > 0 {
                    newContents.append(.interface(interfaceContent))
                }

            }
        }

        return newContents
    }
}

public enum ComponentFilter {
    case plain(filter: String)
    case object(name: String, filters: [String])
}

public struct ContentFilter {
    public let component: String?
    public let filters: [ComponentFilter]

    public init(component: String?, filters: [ComponentFilter]) {
        self.component = component
        self.filters = filters
    }
}

public extension Array where Element == ComponentFilter {
    func getFilter(with name: String) -> ComponentFilter? {

        var found: ComponentFilter?

        for element in self {
            switch element {
            case .plain(let filter):
                if filter == name {
                    found = element
                    break
                }
            case .object(let filter, _):
                if filter == name {
                    found = element
                    break
                }
            default:
                continue
            }
        }

        return found
    }
}
