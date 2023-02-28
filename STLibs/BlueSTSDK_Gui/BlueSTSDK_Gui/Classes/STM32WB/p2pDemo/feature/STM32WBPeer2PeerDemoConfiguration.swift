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


/// Class containing the settings and common structure for the Peer2Peer (P2P) stm32wb demo
public class STM32WBPeer2PeerDemoConfiguration{
    
    private static let ID_TO_DEVICE:[UInt8:DeviceID] = [
        0x83 : DeviceID.DEVICE_1,
        0x84 : DeviceID.DEVICE_2,
        0x87 : DeviceID.DEVICE_3,
        0x88 : DeviceID.DEVICE_4,
        0x89 : DeviceID.DEVICE_5,
        0x8A : DeviceID.DEVICE_6
    ];
    
    /// id used for the device node
    public static var WB_DEVICE_NODE_IDS = ID_TO_DEVICE.keys
    
    /// id used for the router node
    public static let WB_ROUTER_NODE_ID = UInt8(0x85)

    
    /// tell if the node is a valid node for the P2P demo
    ///
    /// - Parameter node: node to test
    /// - Returns: true if the node is manage by this demo
    public static func isValidNode(_ node:BlueSTSDKNode) -> Bool{
        return isValidRouterNode(node) || isValidDeviceNode(node)
    }
    
    public static func isValidRouterNode(_ node:BlueSTSDKNode) -> Bool{
        let nodeId = node.typeId;
        return node.type == .nucleo &&  nodeId == WB_ROUTER_NODE_ID;
    }
    
    public static func isValidDeviceNode(_ node:BlueSTSDKNode) -> Bool{
        let nodeId = node.typeId;
        return (node.type == .WB_BOARD && WB_DEVICE_NODE_IDS.contains(nodeId)) || node.type == .WBA_BOARD;
    }
    
    
    /// map the characteristics and the feature used by this demo
    /// - Returns: map containing the characteristics and feature used by this demo
    public static func getCharacteristicMapping() -> [CBUUID:[AnyClass]]{
        var temp:[CBUUID:[AnyClass]]=[:]
        temp.updateValue([STM32WBControlLedFeature.self,STM32WBProtocolRadioRebootFeature.self],
                         forKey: CBUUID(string: "0000fe41-8e22-4541-9d4c-21edae82ed19"))
        temp.updateValue([STM32WBSwitchStatusFeature.self], forKey: CBUUID(string: "0000fe42-8e22-4541-9d4c-21edae82ed19"))
        temp.updateValue([STM32WBNetworkStatusFeature.self], forKey: CBUUID(string: "0000fe51-8e22-4541-9d4c-21edae82ed19"))
        return temp;
    }

    
    /// enum containing the different device id
    public enum DeviceID : UInt8, CustomStringConvertible,CaseIterable{
        public var description:String {
            return "\(self.rawValue)"
        }
        
        public typealias RawValue = UInt8
        case DEVICE_1 = 0x01
        case DEVICE_2 = 0x02
        case DEVICE_3 = 0x03
        case DEVICE_4 = 0x04
        case DEVICE_5 = 0x05
        case DEVICE_6 = 0x06
        case ALL = 0x00
        
        static public func fromBoardId(_ id:UInt8)->DeviceID?{
            
            return STM32WBPeer2PeerDemoConfiguration.ID_TO_DEVICE[id]
        }
        
    }
}
