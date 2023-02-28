/*
 * Copyright (c) 2019  STMicroelectronics – All rights reserved
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

public class BlueSTSDKAskFwUpgradeDialog {
    
    private static let NEW_FW_ALERT_TITLE = {
        return  NSLocalizedString("New Firmware",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueSTSDKAskFwUpgradeDialog.self),
                                  value: "New Firmware",
                                  comment: "New Firmware");
    }();
    
    private static let NEW_FW_ALERT_MESSAGE_FORMAT = {
        return  NSLocalizedString("New firmware available.\nUpgrade to %@?",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueSTSDKAskFwUpgradeDialog.self),
                                  value: "New firmware available.\nUpgrade to %@?",
                                  comment: "New firmware available.\nUpgrade to %@?");
    }();
    
    private static let NEW_FW_ALERT_YES = {
        return  NSLocalizedString("Yes",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueSTSDKAskFwUpgradeDialog.self),
                                  value: "Yes",
                                  comment: "Yes");
    }();
    
    private static let NEW_FW_ALERT_NO = {
        return  NSLocalizedString("No",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueSTSDKAskFwUpgradeDialog.self),
                                  value: "No",
                                  comment: "No");
    }();
    
    
    public static func askToUpgrade(node:BlueSTSDKNode, file:URL, vc:UIViewController){
        let message = String(format: BlueSTSDKAskFwUpgradeDialog.NEW_FW_ALERT_MESSAGE_FORMAT,
                             file.lastPathComponent)
        let question = UIAlertController(title: BlueSTSDKAskFwUpgradeDialog.NEW_FW_ALERT_TITLE,
                                         message: message,
                                         preferredStyle: .alert)
        
        let upgrade = UIAlertAction(
            title:BlueSTSDKAskFwUpgradeDialog.NEW_FW_ALERT_YES,
            style: .default){ _ in
                let fwUpgradeVc = BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: node,fwRemoteUrl: file)
                
                if let navVc = vc as? UINavigationController{
                    navVc.pushViewController(fwUpgradeVc, animated: true)
                }else{
                    if let navVC = vc.navigationController {
                        navVC.pushViewController(fwUpgradeVc, animated: true)
                    }else{
                        vc.present(fwUpgradeVc, animated: false, completion: nil)
                    }// if has nav controller
                }// if is navController
            }
        
        let cancel = UIAlertAction(title: BlueSTSDKAskFwUpgradeDialog.NEW_FW_ALERT_NO,
                                   style: .cancel,
                                   handler: nil)
        
        question.addAction(upgrade)
        question.addAction(cancel)
        
        vc.present(question, animated: true, completion: nil)
    }
}
