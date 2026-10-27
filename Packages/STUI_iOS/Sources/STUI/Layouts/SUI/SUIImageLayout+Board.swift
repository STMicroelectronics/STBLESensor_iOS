//
//  SUIImageLayout+Board.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import SwiftUI

public extension SUIImageLayout {
    struct Boards {
        
        private static func loadBoard(_ name: String) -> Image {
            return Image(name, bundle: .module)
        }

        public static var stevalWesu1: Image { loadBoard("real_board_steval_wesu1") }
        public static var nucleo: Image { loadBoard("board_nucleo") }
        public static var sensorTile: Image { loadBoard("board_sensorTile") }
        public static var sensorTileBox: Image { loadBoard("board_sensorTile_box") }
        public static var blueCoin: Image { loadBoard("board_blueCoin") }
        public static var stEvalBCN002V1: Image { loadBoard("board_blueNRGTile") }
        public static var stEvalSTWINKIT1: Image { loadBoard("board_sensorTile_box") }
        public static var stEvalSTWINKT1B: Image { loadBoard("board_sensorTile_box") }
        public static var proteus: Image { loadBoard("real_board_proteus") }
        public static var stSysSBU06: Image { loadBoard("real_board_stysys_sbu06") }
        public static var sensorTileBoxPro: Image { loadBoard("real_board_sensortilebox_pro") }
        public static var bcnwbcb: Image { loadBoard("real_board_eval_bcnwbcb") } //PEZZ
        public static var polaris: Image { loadBoard("real_board_polaris") }
        public static var bl4s5iIot01a: Image { loadBoard("real_board_b_l4s5i_iot01a") }
    }
}
