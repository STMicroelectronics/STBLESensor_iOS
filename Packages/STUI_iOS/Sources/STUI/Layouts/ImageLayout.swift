//
//  ImageLayout.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public struct ImageSize {
    public static var extraSmall: CGSize = CGSize(width: 20, height: 20)
    public static var small: CGSize = CGSize(width: 24, height: 24)
    public static var medium: CGSize = CGSize(width: 40, height: 40)
    public static var big: CGSize = CGSize(width: 100, height: 100)
}

public struct ImageLayout {
    public struct Common {
        public static var filter: UIImage? { ImageLayout.image(with: "img_filter") }
        public static var catalog: UIImage? { ImageLayout.image(with: "img_catalog") }
        public static var back: UIImage? { ImageLayout.image(with: "img_back") }
        public static var checkedImage: UIImage? { ImageLayout.image(with: "img_checkmark_circle_fill") }
        public static var uncheckedImage: UIImage? { ImageLayout.image(with: "img_checkmark_circle") }
        public static var refresh: UIImage? { ImageLayout.image(with: "img_refresh") }
        public static var chevronDown: UIImage? { ImageLayout.image(with: "img_chevron_down") }
        public static var info: UIImage? { ImageLayout.image(with: "img_info") }
        public static var sleep: UIImage? { ImageLayout.image(with: "sleepIcon") }
        public static var squareChecked: UIImage? { ImageLayout.image(with: "img_square_checked") }
        public static var squareUnchecked: UIImage? { ImageLayout.image(with: "img_square_unchecked") }
        public static var radioChecked: UIImage? { ImageLayout.image(with: "img_radio_checked") }
        public static var radioUnchecked: UIImage? { ImageLayout.image(with: "img_radio_unchecked") }
        public static var arrowDown: UIImage? { ImageLayout.image(with: "img_arrow_down") }
        public static var arrowUp: UIImage? { ImageLayout.image(with: "img_arrow_up") }
        public static var signal: UIImage? { ImageLayout.image(with: "img_signal") }
        public static var folder: UIImage? { ImageLayout.image(with: "img_folder") }
        public static var lock: UIImage? { ImageLayout.image(with: "ic_lock_24") }
        public static var done: UIImage? { ImageLayout.image(with: "img_done") }
        public static var edit: UIImage? { ImageLayout.image(with: "img_edit") }
        public static var editStop: UIImage? { ImageLayout.image(with: "img_edit_stop") }
        public static var gear: UIImage? { ImageLayout.image(with: "img_gear") }
        public static var accountGear: UIImage? { ImageLayout.image(with: "img_account_gear") }
        public static var star: UIImage? { ImageLayout.image(with: "img_star") }
        public static var starFill: UIImage? { ImageLayout.image(with: "img_star_fill") }
        public static var pin: UIImage? { ImageLayout.image(with: "img_pin") }
        public static var play: UIImage? { ImageLayout.image(with: "ic_play_arrow_24") }
        public static var pause: UIImage? { ImageLayout.image(with: "ic_pause_24") }
        public static var lens: UIImage? { ImageLayout.image(with: "img_lens") }
        public static var tagOutline: UIImage? { ImageLayout.image(with: "img_tag_outline") }
        public static var tagFilled: UIImage? { ImageLayout.image(with: "img_tag_filled") }
        public static var sensors: UIImage? { ImageLayout.image(with: "img_sensors") }
        public static var upload: UIImage? { ImageLayout.image(with: "img_upload") }
        public static var heartUnchecked: UIImage? { ImageLayout.image(with: "img_heart_unchecked") }
        public static var heartChecked: UIImage? { ImageLayout.image(with: "img_heart") }
        public static var delete: UIImage? { ImageLayout.image(with: "img_delete") }
        public static var close: UIImage? { ImageLayout.image(with: "img_close") }
        public static var save: UIImage? { ImageLayout.image(with: "img_save") }
        public static var add: UIImage? { ImageLayout.image(with: "img_add") }
        public static var addRow: UIImage? { ImageLayout.image(with: "img_add_row") }
    }

    public struct SDKV2 {
        public static var images: [String] = [
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
    }

    public static func image(with name: String?, in bundle: Bundle? = STUI.bundle) -> UIImage? {
        guard let name = name else { return nil }
        return UIImage(named: name, in: bundle, compatibleWith: nil)
    }
}
