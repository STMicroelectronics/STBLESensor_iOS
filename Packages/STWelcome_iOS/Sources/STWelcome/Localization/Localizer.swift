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
  public enum Common: String, Localizable { 

      case cancel = "st_common_cancel"
      case edit = "st_common_edit"
      case ok = "st_common_ok"
      case settings = "st_common_settings"
      case stopEditing = "st_common_stopEditing"
      case warning = "st_common_warning"

  }

  public enum Welcome: Localizable { 

    public enum Action: String, Localizable { 
        case accept = "st_welcome_action_accept"
    }
    public enum PageFive: String, Localizable { 
        case content = "st_welcome_pageFive_content"
        case next = "st_welcome_pageFive_next"
        case title = "st_welcome_pageFive_title"
    }
    public enum PageFour: String, Localizable { 
        case content = "st_welcome_pageFour_content"
        case next = "st_welcome_pageFour_next"
        case title = "st_welcome_pageFour_title"
    }
    public enum PageOne: String, Localizable { 
        case content = "st_welcome_pageOne_content"
        case next = "st_welcome_pageOne_next"
        case title = "st_welcome_pageOne_title"
    }
    public enum PageSeven: String, Localizable { 
        case content = "st_welcome_pageSeven_content"
        case next = "st_welcome_pageSeven_next"
        case title = "st_welcome_pageSeven_title"
    }
    public enum PageSix: String, Localizable { 
        case content = "st_welcome_pageSix_content"
        case next = "st_welcome_pageSix_next"
        case title = "st_welcome_pageSix_title"
    }
    public enum PageThree: String, Localizable { 
        case content = "st_welcome_pageThree_content"
        case next = "st_welcome_pageThree_next"
        case title = "st_welcome_pageThree_title"
    }
    public enum PageTwo: String, Localizable { 
        case content = "st_welcome_pageTwo_content"
        case next = "st_welcome_pageTwo_next"
        case title = "st_welcome_pageTwo_title"
    }

  }

}
// swiftlint:enable trailing_whitespace
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name
// swiftlint:enable vertical_whitespace
