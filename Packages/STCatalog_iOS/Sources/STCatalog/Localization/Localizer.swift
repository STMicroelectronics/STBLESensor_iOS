//
//  Localizer.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

// swiftlint:disable superfluous_disable_command
// swiftlint:disable vertical_whitespace

import Foundation
import STCore

// swiftlint:disable trailing_whitespace
// swiftlint:disable file_length
// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name

public extension Localizable {
    var localizedKey: String { "st" }
}

public enum Localizer {
  public enum Catalog: Localizable { 

    public enum Text: String, Localizable { 
        case filters = "st_catalog_text_filters"
        case title = "st_catalog_text_title"
    }

  }

  public enum CatalogDetail: Localizable { 

    public enum Action: String, Localizable { 
        case datasheets = "st_catalogDetail_action_datasheets"
        case firmware = "st_catalogDetail_action_firmware"
        case showDetail = "st_catalogDetail_action_showDetail"
    }
    public enum Text: String, Localizable { 
        case availableDemos = "st_catalogDetail_text_availableDemos"
        case exampleVideo = "st_catalogDetail_text_exampleVideo"
        case title = "st_catalogDetail_text_title"
    }

  }

  public enum CatalogFirmware: Localizable { 

    public enum Text: String, Localizable { 
        case title = "st_catalogFirmware_text_title"
    }

  }

  public enum Common: String, Localizable { 

      case cancel = "st_common_cancel"
      case edit = "st_common_edit"
      case ok = "st_common_ok"
      case settings = "st_common_settings"
      case stopEditing = "st_common_stopEditing"
      case warning = "st_common_warning"

  }

}
// swiftlint:enable trailing_whitespace
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name
// swiftlint:enable vertical_whitespace
