/*
 * Copyright (c) 2017  STMicroelectronics – All rights reserved
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
import BlueSTSDK_Gui

public extension BlueSTSDKNode {
    
    
    /// get node board image, in function of its type
    ///
    /// - Returns: node board type log, or null if unknown
    @objc func getImage()->UIImage?{
        let bundle = Bundle.main;
        
        switch (self.type){
            case .STEVAL_WESU1:
                return UIImage(named:"steval_wesu1_reset_position.png" , in: bundle, compatibleWith: nil);
            case .nucleo, .NUCLEO_F401RE, .NUCLEO_L053R8, .NUCLEO_L476RG, .NUCLEO_F446RE:
                return UIImage(named: "board_nucleo", in: bundle, compatibleWith: nil);
            case .sensor_Tile:
                return UIImage(named: "board_sensorTile", in: bundle, compatibleWith: nil);
            case .sensor_Tile_Box:
                return UIImage(named: "board_sensorTile_box", in: bundle, compatibleWith: nil);
            case .blue_Coin:
                return UIImage(named: "board_blueCoin", in: bundle, compatibleWith: nil);
            case .STEVAL_BCN002V1:
                return UIImage(named: "board_blueNRGTile", in: bundle, compatibleWith: nil);
            case .STEVAL_STWINKIT1:
                return UIImage(named: "board_sensorTile_box", in: bundle, compatibleWith: nil);
            case .STEVAL_STWINKT1B:
                return UIImage(named: "board_sensorTile_box", in: bundle, compatibleWith: nil);
            case .PROTEUS:
                return UIImage(named: "real_board_proteus", in: bundle, compatibleWith: nil);
            case .STSYS_SBU06:
                return UIImage(named: "real_board_stysys_sbu06", in: bundle, compatibleWith: nil);
            case .B_L475E_IOT01A, .discovery_IOT01A:
                return UIImage(named: "real_board_b_l4s5i_iot01a", in: bundle, compatibleWith: nil);
            case .POLARIS:
                return UIImage(named: "real_board_polaris", in: bundle, compatibleWith: nil);
            case .SENSOR_TILE_BOX_PRO:
                return UIImage(named: "real_board_sensortilebox_pro", in: bundle, compatibleWith: nil);
            case .STEVAL_IDB008VX, .generic, .B_U585I_IOT02A, .WB_BOARD, .STWIN_BOX:
                return nil;
            @unknown default:
                return nil
        }
    }
    
}
