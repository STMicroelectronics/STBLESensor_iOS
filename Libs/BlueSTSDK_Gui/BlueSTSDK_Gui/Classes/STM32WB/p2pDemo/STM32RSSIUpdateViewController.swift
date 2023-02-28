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

/// View Controller that will periodically (every 2 seconds) request and display the rssi value
public class STM32WBRSSIUpdateViewController : UIViewController, BlueSTSDKDemoViewProtocol{
    
    private static let RSSI_UPDATE_INTERVAL:TimeInterval = 2.0
    private let WAITING = {
        return  NSLocalizedString("Waiting...",
                                  tableName: nil,
                                  bundle: Bundle(for: STM32WBRSSIUpdateViewController.self),
                                  value: "Waiting...",
                                  comment: "Waiting...");
    }();
    
    
    /// node where query the rssi
    public var node:BlueSTSDKNode!;
    public var menuDelegate: BlueSTSDKViewControllerMenuDelegate?
    
    /// label where show the rssi
    @IBOutlet weak var mRssiLabel: UILabel!
    
    /// queue where post the rssi update request
    private var mRssiUpdateQueue:DispatchQueue!
    
    /// task to request the rssi value
    fileprivate func postRssiRequestUpdate(){
        mRssiUpdateQueue.asyncAfter(deadline: DispatchTime.now() + STM32WBRSSIUpdateViewController.RSSI_UPDATE_INTERVAL){ [weak self] in
            if let n = self?.node, n.isConnected(){
                n.readRssi()
            }//if
        }//asyncAfter
    }//postRssiRequestUpdate
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mRssiUpdateQueue = DispatchQueue(label: "RssiUpdateTask")
        mRssiLabel.text = WAITING
    }
    
    private func startRssiUpdateRequest(){
        node.addBleConnectionParamiterDelegate(self)
        postRssiRequestUpdate()
    }
    
    private func stopRssiUpdateRequest(){
        node.removeBleConnectionParamiterDelegate(self)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startRssiUpdateRequest()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopRssiUpdateRequest()
    }
}

extension STM32WBRSSIUpdateViewController : BlueSTSDKNodeBleConnectionParamDelegate{
    private static let RSSI_FORMAT = "%d [dBm]"
    
    /// Function called when a new rssi is available
    ///
    /// - Parameters:
    ///   - node: node that upgrade the node
    ///   - newRssi: new rssi value
    public func node(_ node: BlueSTSDKNode, didChangeRssi newRssi: Int) {
        DispatchQueue.main.async {
            self.mRssiLabel.text = String(format: STM32WBRSSIUpdateViewController.RSSI_FORMAT, newRssi)
        }
        postRssiRequestUpdate()
    }
}
