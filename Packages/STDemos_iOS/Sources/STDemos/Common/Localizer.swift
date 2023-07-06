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
  public enum Battery: Localizable { 

    public enum Text: String, Localizable { 
        case title = "st_battery_text_title"
    }

  }

  public enum BlueVoice: String, Localizable { 

      case beamForming = "st_blueVoice_beamForming"
      case codec = "st_blueVoice_codec"
      case samplingFrequency = "st_blueVoice_samplingFrequency"
      case volume = "st_blueVoice_volume"

  }

  public enum Common: String, Localizable { 

      case cancel = "st_common_cancel"
      case edit = "st_common_edit"
      case ok = "st_common_ok"
      case settings = "st_common_settings"
      case stopEditing = "st_common_stopEditing"
      case warning = "st_common_warning"

  }

  public enum Compass: Localizable { 

    public enum Calibration: String, Localizable { 
        case message = "st_compass_calibration_message"
        case startButtonContentDesc = "st_compass_calibration_startButtonContentDesc"
        case title = "st_compass_calibration_title"
    }
    public enum Orientation: String, Localizable { 
        case est = "st_compass_orientation_est"
        case north = "st_compass_orientation_north"
        case northEst = "st_compass_orientation_northEst"
        case northWest = "st_compass_orientation_northWest"
        case south = "st_compass_orientation_south"
        case southEst = "st_compass_orientation_southEst"
        case southWest = "st_compass_orientation_southWest"
        case west = "st_compass_orientation_west"
    }

  }

  public enum DemoList: Localizable { 

    public enum Action: String, Localizable { 
        case openDetailPage = "st_demoList_action_openDetailPage"
    }
    public enum Text: String, Localizable { 
        case loginNeeded = "st_demoList_text_loginNeeded"
        case title = "st_demoList_text_title"
    }

  }

  public enum DeviceCertificate: Localizable { 

    public enum Action: String, Localizable { 
        case hideCert = "st_deviceCertificate_action_hideCert"
        case showCert = "st_deviceCertificate_action_showCert"
    }
    public enum Text: String, Localizable { 
        case certReceived = "st_deviceCertificate_text_certReceived"
        case certRegistered = "st_deviceCertificate_text_certRegistered"
        case deviceId = "st_deviceCertificate_text_deviceId"
        case noCertificate = "st_deviceCertificate_text_noCertificate"
        case register = "st_deviceCertificate_text_register"
        case title = "st_deviceCertificate_text_title"
    }

  }

  public enum Extconf: Localizable { 

    public enum Command: Localizable { 
      public enum Custom: String, Localizable { 
          case booleanTitle = "st_extconf_command_custom_booleanTitle"
          case limitsInt = "st_extconf_command_custom_limitsInt"
          case limitsString = "st_extconf_command_custom_limitsString"
          case maxLimitInt = "st_extconf_command_custom_maxLimitInt"
          case maxLimitString = "st_extconf_command_custom_maxLimitString"
          case minLimitInt = "st_extconf_command_custom_minLimitInt"
          case minLimitString = "st_extconf_command_custom_minLimitString"
      }
      public enum Section: String, Localizable { 
          case boardControlTitle = "st_extconf_command_section_boardControlTitle"
          case boardReportTitle = "st_extconf_command_section_boardReportTitle"
          case boardSecurityTitle = "st_extconf_command_section_boardSecurityTitle"
          case boardSettingsTitle = "st_extconf_command_section_boardSettingsTitle"
          case customCommandsTitle = "st_extconf_command_section_customCommandsTitle"
      }
      public enum Text: String, Localizable { 
          case commandBanksSwapTitle = "st_extconf_command_text_commandBanksSwapTitle"
          case commandChangePINAlertTitle = "st_extconf_command_text_commandChangePINAlertTitle"
          case commandChangePINTitle = "st_extconf_command_text_commandChangePINTitle"
          case commandClearDBExecutedPhrase = "st_extconf_command_text_commandClearDBExecutedPhrase"
          case commandClearDBTitle = "st_extconf_command_text_commandClearDBTitle"
          case commandDFUExecutedPhrase = "st_extconf_command_text_commandDFUExecutedPhrase"
          case commandDFUTitle = "st_extconf_command_text_commandDFUTitle"
          case commandHelpTitle = "st_extconf_command_text_commandHelpTitle"
          case commandInfoTitle = "st_extconf_command_text_commandInfoTitle"
          case commandOffeExcutedPhrase = "st_extconf_command_text_commandOffeExcutedPhrase"
          case commandOffTitle = "st_extconf_command_text_commandOffTitle"
          case commandPowerStatusTitle = "st_extconf_command_text_commandPowerStatusTitle"
          case commandReadBanksFwIdTitle = "st_extconf_command_text_commandReadBanksFwIdTitle"
          case commandReadCertTitle = "st_extconf_command_text_commandReadCertTitle"
          case commandReadCommandTitle = "st_extconf_command_text_commandReadCommandTitle"
          case commandReadCustomCommandTitle = "st_extconf_command_text_commandReadCustomCommandTitle"
          case commandReadSensorsConfigTitle = "st_extconf_command_text_commandReadSensorsConfigTitle"
          case commandSetCertTitle = "st_extconf_command_text_commandSetCertTitle"
          case commandSetDateExecutedPhrase = "st_extconf_command_text_commandSetDateExecutedPhrase"
          case commandSetDateTitle = "st_extconf_command_text_commandSetDateTitle"
          case commandSetNameAlertTitle = "st_extconf_command_text_commandSetNameAlertTitle"
          case commandSetNameTitle = "st_extconf_command_text_commandSetNameTitle"
          case commandSetSensorsConfigTitle = "st_extconf_command_text_commandSetSensorsConfigTitle"
          case commandSetTimeExecutedPhrase = "st_extconf_command_text_commandSetTimeExecutedPhrase"
          case commandSetTimeTitle = "st_extconf_command_text_commandSetTimeTitle"
          case commandSetWiFiTitle = "st_extconf_command_text_commandSetWiFiTitle"
          case commandUIDTitle = "st_extconf_command_text_commandUIDTitle"
          case commandVersionFwTitle = "st_extconf_command_text_commandVersionFwTitle"
      }
    }
    public enum Text: String, Localizable { 
        case mainAlertTitle = "st_extconf_text_mainAlertTitle"
    }

  }

  public enum Firmware: Localizable { 

    public enum Action: String, Localizable { 
        case select = "st_firmware_action_select"
        case upgrade = "st_firmware_action_upgrade"
    }
    public enum Text: String, Localizable { 
        case availableFirmwareList = "st_firmware_text_availableFirmwareList"
        case bankStatus = "st_firmware_text_bankStatus"
        case changelog = "st_firmware_text_changelog"
        case currentRunningFirmware = "st_firmware_text_currentRunningFirmware"
        case extraInfo = "st_firmware_text_extraInfo"
        case firmwareCurrentBankInfo = "st_firmware_text_firmwareCurrentBankInfo"
        case firmwareOtherBankInfo = "st_firmware_text_firmwareOtherBankInfo"
        case firmwarePresent = "st_firmware_text_firmwarePresent"
        case firmwareUnknown = "st_firmware_text_firmwareUnknown"
        case installSelectedFirmware = "st_firmware_text_installSelectedFirmware"
        case mcuType = "st_firmware_text_mcuType"
        case name = "st_firmware_text_name"
        case otherBankStatus = "st_firmware_text_otherBankStatus"
        case selectedFirmwareDescriptionTitle = "st_firmware_text_selectedFirmwareDescriptionTitle"
        case selectFirmware = "st_firmware_text_selectFirmware"
        case swapToThisBank = "st_firmware_text_swapToThisBank"
        case title = "st_firmware_text_title"
        case updateAvailableMessage = "st_firmware_text_updateAvailableMessage"
        case updateAvailableTitle = "st_firmware_text_updateAvailableTitle"
        case upgrade = "st_firmware_text_upgrade"
        case version = "st_firmware_text_version"
    }

  }

  public enum FitnessActivity: Localizable { 

    public enum Activity: String, Localizable { 
        case bicepsCurl = "st_fitnessActivity_activity_bicepsCurl"
        case none = "st_fitnessActivity_activity_none"
        case pushUp = "st_fitnessActivity_activity_pushUp"
        case squat = "st_fitnessActivity_activity_squat"
    }
    public enum Common: String, Localizable { 
        case counterLabelFormatter = "st_fitnessActivity_common_counterLabelFormatter"
    }

  }

  public enum JsonNfc: Localizable { 

    public enum Action: String, Localizable { 
        case writeToNfc = "st_jsonNfc_action_writeToNfc"
    }
    public enum Authentication: String, Localizable { 
        case none = "st_jsonNfc_authentication_none"
        case shared = "st_jsonNfc_authentication_shared"
        case wpa = "st_jsonNfc_authentication_wpa"
        case wpa2 = "st_jsonNfc_authentication_wpa2"
        case wpapsk = "st_jsonNfc_authentication_wpapsk"
        case wpatwopsk = "st_jsonNfc_authentication_wpatwopsk"
    }
    public enum Encryption: String, Localizable { 
        case aes = "st_jsonNfc_encryption_aes"
        case none = "st_jsonNfc_encryption_none"
        case tkip = "st_jsonNfc_encryption_tkip"
        case wep = "st_jsonNfc_encryption_wep"
    }
    public enum Text: String, Localizable { 
        case address = "st_jsonNfc_text_address"
        case authenticationType = "st_jsonNfc_text_authenticationType"
        case cellularPhone = "st_jsonNfc_text_cellularPhone"
        case demoTitle = "st_jsonNfc_text_demoTitle"
        case encryptionType = "st_jsonNfc_text_encryptionType"
        case formattedName = "st_jsonNfc_text_formattedName"
        case homeAddress = "st_jsonNfc_text_homeAddress"
        case homeEmail = "st_jsonNfc_text_homeEmail"
        case homePhone = "st_jsonNfc_text_homePhone"
        case insertText = "st_jsonNfc_text_insertText"
        case insertUrl = "st_jsonNfc_text_insertUrl"
        case name = "st_jsonNfc_text_name"
        case organization = "st_jsonNfc_text_organization"
        case password = "st_jsonNfc_text_password"
        case ssid = "st_jsonNfc_text_ssid"
        case textTitle = "st_jsonNfc_text_textTitle"
        case title = "st_jsonNfc_text_title"
        case url = "st_jsonNfc_text_url"
        case urlTitle = "st_jsonNfc_text_urlTitle"
        case vCardTitle = "st_jsonNfc_text_vCardTitle"
        case wifiTitle = "st_jsonNfc_text_wifiTitle"
        case workAddress = "st_jsonNfc_text_workAddress"
        case workEmail = "st_jsonNfc_text_workEmail"
        case workPhone = "st_jsonNfc_text_workPhone"
    }
    public enum Url: String, Localizable { 
        case http = "st_jsonNfc_url_http"
        case https = "st_jsonNfc_url_https"
    }

  }

  public enum NeaiAnomalyDetection: Localizable { 

    public enum Action: String, Localizable { 
        case resetKnowledge = "st_neaiAnomalyDetection_action_resetKnowledge"
        case start = "st_neaiAnomalyDetection_action_start"
        case stop = "st_neaiAnomalyDetection_action_stop"
    }
    public enum Aiengine: Localizable { 
      public enum Phase: String, Localizable { 
          case busy = "st_neaiAnomalyDetection_aiengine_phase_busy"
          case detection = "st_neaiAnomalyDetection_aiengine_phase_detection"
          case idle = "st_neaiAnomalyDetection_aiengine_phase_idle"
          case idleTrained = "st_neaiAnomalyDetection_aiengine_phase_idleTrained"
          case learning = "st_neaiAnomalyDetection_aiengine_phase_learning"
          case null = "st_neaiAnomalyDetection_aiengine_phase_null"
      }
      public enum State: String, Localizable { 
          case boardError = "st_neaiAnomalyDetection_aiengine_state_boardError"
          case initNotCalled = "st_neaiAnomalyDetection_aiengine_state_initNotCalled"
          case knowledgeError = "st_neaiAnomalyDetection_aiengine_state_knowledgeError"
          case minimalLearningDone = "st_neaiAnomalyDetection_aiengine_state_minimalLearningDone"
          case notEnoughLearning = "st_neaiAnomalyDetection_aiengine_state_notEnoughLearning"
          case null = "st_neaiAnomalyDetection_aiengine_state_null"
          case ok = "st_neaiAnomalyDetection_aiengine_state_ok"
          case unknownError = "st_neaiAnomalyDetection_aiengine_state_unknownError"
      }
    }
    public enum Results: Localizable { 
      public enum Status: String, Localizable { 
          case anomaly = "st_neaiAnomalyDetection_results_status_anomaly"
          case normal = "st_neaiAnomalyDetection_results_status_normal"
          case null = "st_neaiAnomalyDetection_results_status_null"
      }
    }
    public enum Text: String, Localizable { 
        case aiengineTitle = "st_neaiAnomalyDetection_text_aiengineTitle"
        case commands = "st_neaiAnomalyDetection_text_commands"
        case detecting = "st_neaiAnomalyDetection_text_detecting"
        case learning = "st_neaiAnomalyDetection_text_learning"
        case library = "st_neaiAnomalyDetection_text_library"
        case noValue = "st_neaiAnomalyDetection_text_noValue"
        case phaseTitle = "st_neaiAnomalyDetection_text_phaseTitle"
        case progressTitle = "st_neaiAnomalyDetection_text_progressTitle"
        case resourceBusy = "st_neaiAnomalyDetection_text_resourceBusy"
        case resultsTitle = "st_neaiAnomalyDetection_text_resultsTitle"
        case similarityTitle = "st_neaiAnomalyDetection_text_similarityTitle"
        case stateTilte = "st_neaiAnomalyDetection_text_stateTilte"
        case statusTitle = "st_neaiAnomalyDetection_text_statusTitle"
        case title = "st_neaiAnomalyDetection_text_title"
        case titleTabBar = "st_neaiAnomalyDetection_text_titleTabBar"
        case workingProgress = "st_neaiAnomalyDetection_text_workingProgress"
    }

  }

  public enum NeaiClassification: Localizable { 

    public enum Action: String, Localizable { 
        case start = "st_neaiClassification_action_start"
        case stop = "st_neaiClassification_action_stop"
    }
    public enum Alert: String, Localizable { 
        case cancelBtnLabel = "st_neaiClassification_alert_cancelBtnLabel"
        case message = "st_neaiClassification_alert_message"
        case startBtnLabel = "st_neaiClassification_alert_startBtnLabel"
        case title = "st_neaiClassification_alert_title"
    }
    public enum Outlier: String, Localizable { 
        case no = "st_neaiClassification_outlier_no"
        case titile = "st_neaiClassification_outlier_titile"
        case yes = "st_neaiClassification_outlier_yes"
    }
    public enum Phase: String, Localizable { 
        case busy = "st_neaiClassification_phase_busy"
        case classification = "st_neaiClassification_phase_classification"
        case idle = "st_neaiClassification_phase_idle"
        case null = "st_neaiClassification_phase_null"
    }
    public enum State: String, Localizable { 
        case boardError = "st_neaiClassification_state_boardError"
        case initNotCalled = "st_neaiClassification_state_initNotCalled"
        case knowledgeError = "st_neaiClassification_state_knowledgeError"
        case minimalLearningDone = "st_neaiClassification_state_minimalLearningDone"
        case notEnoughLearning = "st_neaiClassification_state_notEnoughLearning"
        case null = "st_neaiClassification_state_null"
        case ok = "st_neaiClassification_state_ok"
        case unknownError = "st_neaiClassification_state_unknownError"
    }
    public enum Text: String, Localizable { 
        case aiEngine = "st_neaiClassification_text_aiEngine"
        case mostProbableClass = "st_neaiClassification_text_mostProbableClass"
        case neaiCommands = "st_neaiClassification_text_neaiCommands"
        case noValue = "st_neaiClassification_text_noValue"
        case phaseTitle = "st_neaiClassification_text_phaseTitle"
        case probabilities = "st_neaiClassification_text_probabilities"
        case resourceBusy = "st_neaiClassification_text_resourceBusy"
        case results = "st_neaiClassification_text_results"
        case showAllClasses = "st_neaiClassification_text_showAllClasses"
        case startClassificationMessage = "st_neaiClassification_text_startClassificationMessage"
        case state = "st_neaiClassification_text_state"
        case stopClassificationMessage = "st_neaiClassification_text_stopClassificationMessage"
        case titleBar = "st_neaiClassification_text_titleBar"
        case unknown = "st_neaiClassification_text_unknown"
    }
    public enum Title: String, Localizable { 
        case nClass = "st_neaiClassification_title_nClass"
        case oneClass = "st_neaiClassification_title_oneClass"
        case wrongClass = "st_neaiClassification_title_wrongClass"
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

  public enum Updatewifi: Localizable { 

    public enum Action: String, Localizable { 
        case done = "st_updatewifi_action_done"
    }
    public enum Text: String, Localizable { 
        case credentialTitle = "st_updatewifi_text_credentialTitle"
        case password = "st_updatewifi_text_password"
        case security = "st_updatewifi_text_security"
        case ssid = "st_updatewifi_text_ssid"
    }

  }

}
// swiftlint:enable trailing_whitespace
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name
// swiftlint:enable vertical_whitespace
