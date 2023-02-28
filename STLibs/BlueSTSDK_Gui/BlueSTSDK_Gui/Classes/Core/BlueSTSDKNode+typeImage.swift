 /*
  * Copyright (c) 2018  STMicroelectronics – All rights reserved
  * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
  *
  * Redistribution and use in source and binary forms, with or without modification,
  * are permitted provided that the following conditions are met:
  *
  * - Redistributions of source code must retain the above copyright notice, this list of conditions
  *   and the following disclaimer.
  *
  * - Redistributions in binary form must reproduce the above copyright notice, this list of
  *   conditions and the following disclaimer in the documentation and/or other materials provided
  *   with the distribution.
  *
  * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
  *   STMicroelectronics company nor the names of its contributors may be used to endorse or
  *   promote products derived from this software without specific prior written permission.
  *
  * - All of the icons, pictures, logos and other images that are provided with the source code
  *   in a directory whose title begins with st_images may only be used for internal purposes and
  *   shall not be redistributed to any third party or modified in any way.
  *
  * - Any redistributions in binary form shall not include the capability to display any of the
  *   icons, pictures, logos and other images that are provided with the source code in a directory
  *   whose title begins with st_images.
  *
  * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
  * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
  * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
  * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
  * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
  * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
  * OF SUCH DAMAGE.
  */

import Foundation
import BlueSTSDK
import UIKit

public extension BlueSTSDKNode{
    
    func getTypeImage()->UIImage?{
        switch type {
        case .generic:
            return BlueSTSDK_Gui.bundleImage(named: "generic_board")
        case .discovery_IOT01A:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_b_l475e_iot01bx")
        case .STEVAL_WESU1:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_wesu")
        case .sensor_Tile:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_sensortile")
        case .sensor_Tile_Box:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_sensortilebox")
        case .blue_Coin:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_bluecoin")
        case .STEVAL_IDB008VX:
            return BlueSTSDK_Gui.bundleImage(named: "logo_steval_idb008VX")
        case .STEVAL_BCN002V1:
            return BlueSTSDK_Gui.bundleImage(named: "logo_steval_bnc002V1")
        case .STEVAL_STWINKIT1:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_stwinkt1")
        case .STEVAL_STWINKT1B:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_stwinkt1b")
        case .nucleo:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_nucleo")
        case .B_L475E_IOT01A:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_b_l4s5i_iot01a")
        case .B_U585I_IOT02A:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_b_l475e_iot01bx")
        case .POLARIS:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_astra")
        case .SENSOR_TILE_BOX_PRO:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_sensortilebox_pro")
        case .STWIN_BOX:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_stwinbx1")
        case .PROTEUS:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_proteus")
        case .STSYS_SBU06:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_stysys_sbu06")
        case .WBA_BOARD:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_wba")
        case .WB_BOARD, .NUCLEO_F401RE, .NUCLEO_F446RE, .NUCLEO_L476RG, .NUCLEO_L053R8:
            return BlueSTSDK_Gui.bundleImage(named: "real_board_pnucleo_wb55")
        @unknown default:
            return BlueSTSDK_Gui.bundleImage(named: "generic_board")
        }
    }
    
}
