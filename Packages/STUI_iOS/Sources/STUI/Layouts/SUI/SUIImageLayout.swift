//
//  SUIImageLayout.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public struct SUIImageSize {
    public static let extraSmall: CGFloat = 20
    public static let small: CGFloat = 24
    public static let medium: CGFloat = 40
    public static let big: CGFloat = 100
}

public struct SUIImageLayout {
    private static func load(_ name: String) -> Image {
        return Image(name, bundle: STUI.bundle)
    }

    public struct Common {
        public static var filter: Image { load("img_filter") }
        public static var catalog: Image { load("img_catalog") }
        public static var back: Image { load("img_back") }
        public static var checkedImage: Image { load("img_checkmark_circle_fill") }
        public static var uncheckedImage: Image { load("img_checkmark_circle") }
        public static var refresh: Image { load("img_refresh") }
        public static var chevronDown: Image { load("img_chevron_down") }
        public static var info: Image { load("img_info") }
        public static var infoFilled: Image { load("img_info_filled") }
        public static var warningFilled: Image { load("img_warning_filled") }
        public static var sleep: Image { load("sleepIcon") }
        public static var squareChecked: Image { load("img_square_checked") }
        public static var squareUnchecked: Image { load("img_square_unchecked") }
        public static var radioChecked: Image { load("img_radio_checked") }
        public static var radioUnchecked: Image { load("img_radio_unchecked") }
        public static var arrowDown: Image { load("img_arrow_down") }
        public static var arrowUp: Image { load("img_arrow_up") }
        public static var signal: Image { load("img_signal") }
        public static var folder: Image { load("img_folder") }
        public static var lock: Image { load("ic_lock_24") }
        public static var done: Image { load("img_done") }
        public static var edit: Image { load("img_edit") }
        public static var editStop: Image { load("img_edit_stop") }
        public static var gear: Image { load("img_gear") }
        public static var gearFilled: Image { load("img_gear_filled") }
        public static var accountGear: Image { load("img_account_gear") }
        public static var moreVertical: Image { load("img_more_vertical") }
        public static var star: Image { load("img_star") }
        public static var starFill: Image { load("img_star_fill") }
        public static var pin: Image { load("img_pin") }
        public static var filterOn: Image { load("filter_alt_on") }
        public static var filterOff: Image { load("filter_alt_off") }
        public static var play: Image { load("ic_play_arrow_24") }
        public static var playFilled: Image { load("ic_play_arrow_24_filled") }
        public static var pause: Image { load("ic_pause_24") }
        public static var stopFilled: Image { load("ic_stop_24_filled") }
        public static var stop: Image { load("ic_stop_24") }
        public static var lens: Image { load("img_lens") }
        public static var zoom_out: Image { load("ic_zoom_out") }
        public static var tagOutline: Image { load("img_tag_outline") }
        public static var tagFilled: Image { load("img_tag_filled") }
        public static var sensors: Image { load("img_sensors") }
        public static var upload: Image { load("img_upload") }
        public static var logs: Image { load("img_logs") }
        public static var heartUnchecked: Image { load("img_heart_unchecked") }
        public static var heartChecked: Image { load("img_heart") }
        public static var delete: Image { load("img_delete") }
        public static var close: Image { load("img_close") }
        public static var save: Image { load("img_save") }
        public static var add: Image { load("img_add") }
        public static var addRow: Image { load("img_add_row") }
        public static var shopping: Image { load("img_shopping") }
        public static var wiki: Image { load("img_wiki") }
        public static var products: Image { load("img_products") }
    }
    
    public struct SDKV2 {
        private static let images: [String] = [
            /** 0  -> Low Battery */
            "battery_0",
            /** 1  -> Battery ok */
            "battery_60",
            /** 2  -> Battery Full */
            "battery_100",
            /** 3  -> Battery Charging */
            "battery_80c",
            /** 4  -> Message */
            "ic_message_24",
            /** 5  -> Warning/Alarm */
            "ic_warning_24",
            /** 6  -> Error */
            "ic_error_24",
            /** 7  -> Ready */
            "ic_ready_outline_24",
            /** 8  -> Waiting Pairing */
            "ic_bluetooth_waiting_24",
            /** 9  -> Paired */
            "ic_bluetooth_connected_24",
            /** 10 -> Log On going */
            "ic_log_on_going_24",
            /** 11 -> Memory Full */
            "ic_disc_full_24",
            /** 12 -> Connected to Cloud */
            "ic_cloud_done_24",
            /** 13 -> Connecting to Cloud */
            "ic_cloud_upload_24",
            /** 14 -> Cloud not Connected */
            "ic_cloud_off_24",
            /** 15 -> GPS found */
            "ic_gps_fixed_24",
            /** 16 -> GPS not Found */
            "ic_gps_not_fixed_24",
            /** 17 -> GPS Off */
            "ic_gps_off_24",
            /** 18 -> Led On */
            "ic_flash_on_24",
            /** 19 -> Led Off */
            "ic_flash_off_24",
            /** 20 -> Link On */
            "ic_link_on_24",
            /** 21 -> Link Off */
            "ic_link_off_24",
            /** 22 -> Wi-Fi On */
            "ic_wifi_on_24",
            /** 23 -> Wi-Fi Off */
            "ic_wifi_off_24",
            /** 24 -> Wi-Fi Tethering */
            "ic_wifi_tethering_24",
            /** 25 -> Low Power */
            "ic_battery_saver_24dp",
            /** 26 -> Sleeping */
            "ic_sleep_hotel_24",
            /** 27 -> High Power */
            "ic_battery_charging_full_24",
            /** 28 -> Microphone On */
            "ic_mic_on_24",
            /** 29 -> Microphone Off */
            "ic_mic_off_24",
            /** 30 -> Play */
            "ic_play_arrow_24",
            /** 31 -> Pause */
            "ic_pause_24",
            /** 32 -> Stop */
            "ic_stop_24",
            /** 33 -> Sync On */
            "ic_sync_on_24",
            /** 34 -> Sync Off */
            "ic_sync_off_24",
            /** 35 -> Sync Error */
            "ic_sync_error_24",
            /** 36 -> Lock */
            "ic_lock_24",
            /** 37 -> Not Lock */
            "ic_lock_open_24",
            /** 38 -> Star */
            "ic_star_24",
            /** 39 -> Very dissatisfied */
            "ic_very_dissatisfied_24",
            /** 40 -> Dissatisfied */
            "ic_dissatisfied_24",
            /** 41 -> Satisfied */
            "ic_satisfied_24",
            /** 42 -> Very satisfied */
            "ic_very_satisfied_24",
            /** 43 -> Sick */
            "ic_sick_24",
            /** 44 -> Share */
            "ic_share_24",
            /** 45 -> Filter 1 */
            "ic_filter_1",
            /** 46 -> Filter 2 */
            "ic_filter_2",
            /** 47 -> Filter 3 */
            "ic_filter_3",
            /** 48 -> Filter 4 */
            "ic_filter_4",
            /** 49 -> Filter 5 */
            "ic_filter_5",
            /** 50 -> Filter 6 */
            "ic_filter_6",
            /** 51 -> Filter 7 */
            "ic_filter_7",
            /** 52 -> Filter 8 */
            "ic_filter_8",
            /** 53 -> Filter 9 */
            "ic_filter_9",
            /** 54 -> Filter 9+ */
            "ic_filter_9plus",
            /** 55 (mMaxIconCode) -> Icon Code not Recognized  */
            "ic_help_24"
        ]
        
        public static func image(for index: Int) -> Image {
            guard index >= 0 && index < images.count else {
                return load("ic_help_24")
            }
            return load(images[index])
        }
    }
    
    public static func image(with name: String?, in bundle: Bundle? = STUI.bundle) -> Image {
        guard let name = name else { return Image(systemName: "questionmark") }
        return Image(name, bundle: bundle)
    }
}
