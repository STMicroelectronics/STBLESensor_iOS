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

/// this is a dummy view controller that will pass the data to its internal view controller
/// that will display the real data
public class BlueMSBoardStatusViewController: BlueMSDemoTabViewController{
    
    private static let BOARD_NAME_FORMAT:String = {
        let bundle = Bundle(for: BlueMSBoardStatusViewController.self)
        return NSLocalizedString("%@", tableName: nil, bundle: bundle,
                                 value: "%@", comment: "")
    }();
    
    private static let BOARD_TYPE_FORMAT:String = {
        let bundle = Bundle(for: BlueMSBoardStatusViewController.self)
        return NSLocalizedString("Type: %@", tableName: nil, bundle: bundle,
                                 value: "Type: %@", comment: "")
    }();
    
    private static let BOARD_ADDRESS_FORMAT:String = {
        let bundle = Bundle(for: BlueMSBoardStatusViewController.self)
        return NSLocalizedString("Address: %@", tableName: nil, bundle: bundle,
                                 value: "Address: %@", comment: "")
    }();
    
    @IBOutlet weak var mBoardName: UILabel!
    @IBOutlet weak var mBoardAddress: UILabel!
    @IBOutlet weak var mBoardType: UILabel!
    
    
    public override func viewDidAppear(_ animated: Bool) {
        mBoardName.text = String(format:BlueMSBoardStatusViewController.BOARD_NAME_FORMAT,node.name)
        mBoardAddress.text = String(format:BlueMSBoardStatusViewController.BOARD_ADDRESS_FORMAT,
                                   node.address ?? "Unknown")
        /*mBoardType.text = String(format:BlueMSBoardStatusViewController.BOARD_TYPE_FORMAT,
                                   BlueSTSDKNode.nodeType(toString: node.type ))*/
    }
    
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        BlueSTSDKDemoViewProtocolUtil.setupDemoProtocol(demo: segue.destination,
                                                    node: self.node,
                                                    menuDelegate: self.menuDelegate);
    }
}
