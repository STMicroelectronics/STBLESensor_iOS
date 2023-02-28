/*******************************************************************************
 * COPYRIGHT(c) 2019 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/


import Foundation

//TODO extend nsobject only to be availabe in Node
@objc public protocol BleAdvertiseInfo : NSObjectProtocol {
    @objc var name:String? {get}
    @objc var address:String? {get}
    @objc var featureMap:UInt32 { get set }
    @objc var deviceId:UInt8 {get}
    @objc var protocolVersion:UInt8 {get}
    @objc var boardType:BlueSTSDKNodeType {get}
    @objc var isSleeping:Bool {get}
    @objc var hasGeneralPurpose:Bool {get}
    @objc var txPower:UInt8 {get}
}

/**
 * Protocol used to decide if we can build a BlueSTSDKNode from a CBPeriperal advertise
 * if we can build an AdvertiseInfo object the sdk will build a node from that infos
 */
//is objc becouse the startScanning is objc
@objc public protocol BlueSTSDKAdvertiseFilter{
    
    /**
     * @param data: advertise data from centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
     * @return nill if the advertise doesn't contain all the needed info, otherwise a info object that is used to build the node
    */
    func filter(_ data:[String:Any])->BleAdvertiseInfo?
}
