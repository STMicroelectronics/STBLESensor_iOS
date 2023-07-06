//
//  ImageLayout+Board.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
import UIKit

public extension ImageLayout {
    struct Boards {
        public static var stevalWesu1: UIImage? = { UIImage(named: "real_board_steval_wesu1", in: .module, compatibleWith: nil) } ()
        public static var nucleo: UIImage? = { UIImage(named: "board_nucleo", in: .module, compatibleWith: nil) } ()
        public static var sensorTile: UIImage? = { UIImage(named: "board_sensorTile", in: .module, compatibleWith: nil) } ()
        public static var sensorTileBox: UIImage? = { UIImage(named: "board_sensorTile_box", in: .module, compatibleWith: nil) } ()
        public static var blueCoin: UIImage? = { UIImage(named: "board_blueCoin", in: .module, compatibleWith: nil) } ()
        public static var stEvalBCN002V1: UIImage? = { UIImage(named: "board_blueNRGTile", in: .module, compatibleWith: nil) } ()
        public static var stEvalSTWINKIT1: UIImage? = { UIImage(named: "board_sensorTile_box", in: .module, compatibleWith: nil) } ()
        public static var stEvalSTWINKT1B: UIImage? = { UIImage(named: "board_sensorTile_box", in: .module, compatibleWith: nil) } ()
        public static var proteus: UIImage? = { UIImage(named: "real_board_proteus", in: .module, compatibleWith: nil) } ()
        public static var stSysSBU06: UIImage? = { UIImage(named: "real_board_stysys_sbu06", in: .module, compatibleWith: nil) } ()
        public static var sensorTileBoxPro: UIImage? = { UIImage(named: "real_board_sensortilebox_pro", in: .module, compatibleWith: nil) } ()
        public static var polaris: UIImage? = { UIImage(named: "real_board_polaris", in: .module, compatibleWith: nil) } ()
        public static var bl4s5iIot01a: UIImage? = { UIImage(named: "real_board_b_l4s5i_iot01a", in: .module, compatibleWith: nil) } ()
    }
}
