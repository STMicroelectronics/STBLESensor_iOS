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

  public enum Home: Localizable { 

    public enum DeviceList: String, Localizable { 
        case screenTitle = "st_home_deviceList_screenTitle"
    }
    public enum NoResultView: Localizable { 
      public enum Text: String, Localizable { 
          case description = "st_home_noResultView_Text_description"
          case title = "st_home_noResultView_Text_title"
      }
      public enum Action: String, Localizable { 
          case discoverProduct = "st_home_noResultView_action_discoverProduct"
      }
    }
    public enum Text: String, Localizable { 
        case catalog = "st_home_text_catalog"
        case filter = "st_home_text_filter"
    }

  }

  public enum NodeFilter: Localizable { 

    public enum Text: String, Localizable { 
        case title = "st_nodeFilter_text_title"
    }

  }

  public enum NodeList: Localizable { 

    public enum Action: String, Localizable { 
        case changeProfile = "st_nodeList_action_changeProfile"
        case login = "st_nodeList_action_login"
        case logout = "st_nodeList_action_logout"
    }
    public enum Text: String, Localizable { 
        case connecting = "st_nodeList_text_connecting"
        case customDtdl = "st_nodeList_text_customDtdl"
        case customEntry = "st_nodeList_text_customEntry"
        case customFirmware = "st_nodeList_text_customFirmware"
        case customModel = "st_nodeList_text_customModel"
        case resetFwDB = "st_nodeList_text_resetFwDB"
        case title = "st_nodeList_text_title"
        case welcome = "st_nodeList_text_welcome"
    }

  }

  public enum Pnpl: Localizable { 

    public enum Action: String, Localizable { 
        case send = "st_pnpl_action_send"
        case uploadFile = "st_pnpl_action_uploadFile"
    }
    public enum Text: String, Localizable { 
        case accelerometer = "st_pnpl_text_accelerometer"
        case acquisitionInfo = "st_pnpl_text_acquisitionInfo"
        case applications = "st_pnpl_text_applications"
        case autoMode = "st_pnpl_text_autoMode"
        case deviceInfo = "st_pnpl_text_deviceInfo"
        case firmwareInfo = "st_pnpl_text_firmwareInfo"
        case gyroscope = "st_pnpl_text_gyroscope"
        case humidity = "st_pnpl_text_humidity"
        case loadConfiguration = "st_pnpl_text_loadConfiguration"
        case logController = "st_pnpl_text_logController"
        case magnetometer = "st_pnpl_text_magnetometer"
        case microphone = "st_pnpl_text_microphone"
        case mlc = "st_pnpl_text_mlc"
        case pressure = "st_pnpl_text_pressure"
        case selectOption = "st_pnpl_text_selectOption"
        case tagsInfo = "st_pnpl_text_tagsInfo"
        case temperature = "st_pnpl_text_temperature"
    }

  }

  public enum UserProfiling: Localizable { 

    public enum LevelProficiency: String, Localizable { 
        case beginnerDescription = "st_userProfiling_levelProficiency_beginnerDescription"
        case beginnerName = "st_userProfiling_levelProficiency_beginnerName"
        case descriptionScreen = "st_userProfiling_levelProficiency_descriptionScreen"
        case developerDescription = "st_userProfiling_levelProficiency_developerDescription"
        case developerName = "st_userProfiling_levelProficiency_developerName"
        case expertDescription = "st_userProfiling_levelProficiency_expertDescription"
        case expertName = "st_userProfiling_levelProficiency_expertName"
        case nextButton = "st_userProfiling_levelProficiency_nextButton"
        case otherDescription = "st_userProfiling_levelProficiency_otherDescription"
        case otherName = "st_userProfiling_levelProficiency_otherName"
        case salesDescription = "st_userProfiling_levelProficiency_salesDescription"
        case salesName = "st_userProfiling_levelProficiency_salesName"
        case studentDescription = "st_userProfiling_levelProficiency_studentDescription"
        case studentName = "st_userProfiling_levelProficiency_studentName"
        case titleScreen = "st_userProfiling_levelProficiency_titleScreen"
    }
    public enum ProfileSelection: String, Localizable { 
        case descriptionScreen = "st_userProfiling_profileSelection_descriptionScreen"
        case nextButton = "st_userProfiling_profileSelection_nextButton"
        case titleScreen = "st_userProfiling_profileSelection_titleScreen"
    }
    public enum StepOne: Localizable { 
      public enum OptionOne: String, Localizable { 
          case content = "st_userProfiling_stepOne_optionOne_content"
          case subtitle = "st_userProfiling_stepOne_optionOne_subtitle"
          case title = "st_userProfiling_stepOne_optionOne_title"
      }
      public enum OptionTwo: String, Localizable { 
          case content = "st_userProfiling_stepOne_optionTwo_content"
          case subtitle = "st_userProfiling_stepOne_optionTwo_subtitle"
          case title = "st_userProfiling_stepOne_optionTwo_title"
      }
      public enum Text: String, Localizable { 
          case navigationTitle = "st_userProfiling_stepOne_text_navigationTitle"
          case next = "st_userProfiling_stepOne_text_next"
          case title = "st_userProfiling_stepOne_text_title"
      }
    }
    public enum StepTwo: Localizable { 
      public enum OptionFour: String, Localizable { 
          case content = "st_userProfiling_stepTwo_optionFour_content"
          case subtitle = "st_userProfiling_stepTwo_optionFour_subtitle"
          case title = "st_userProfiling_stepTwo_optionFour_title"
      }
      public enum OptionOne: String, Localizable { 
          case content = "st_userProfiling_stepTwo_optionOne_content"
          case subtitle = "st_userProfiling_stepTwo_optionOne_subtitle"
          case title = "st_userProfiling_stepTwo_optionOne_title"
      }
      public enum OptionThree: String, Localizable { 
          case content = "st_userProfiling_stepTwo_optionThree_content"
          case subtitle = "st_userProfiling_stepTwo_optionThree_subtitle"
          case title = "st_userProfiling_stepTwo_optionThree_title"
      }
      public enum OptionTwo: String, Localizable { 
          case content = "st_userProfiling_stepTwo_optionTwo_content"
          case subtitle = "st_userProfiling_stepTwo_optionTwo_subtitle"
          case title = "st_userProfiling_stepTwo_optionTwo_title"
      }
      public enum Text: String, Localizable { 
          case navigationTitle = "st_userProfiling_stepTwo_text_navigationTitle"
          case next = "st_userProfiling_stepTwo_text_next"
          case title = "st_userProfiling_stepTwo_text_title"
      }
    }

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
