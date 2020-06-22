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
import BlueSTSDK_Gui

public class BlueMSMainViewController : BlueSTSDKMainViewController {
    
    /**
     *  laod the BlueSTSDKMainView and set the delegate for it
     */
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.delegateAbout = self
        self.delegateNodeList = self
    }
    
    @IBAction func onCreateAppButtonClick(_ sender: UIButton) {
    }
    
    private func getDemoViewController(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate)
        -> UIViewController{
            let storyBoard = UIStoryboard(name: "BlueMS", bundle: nil);
            let mainView = storyBoard.instantiateInitialViewController() as? BlueMSDemosViewController
            mainView?.node=node;
            mainView?.menuDelegate = menuManager;
            return mainView!;
    }
    
    
    @IBAction func onBLEToolboxButtonPressed(_ sender: UIButton) {
    }
    
    /**
     *  when the user select a node show the main view form the DemoView storyboard
     *
     *  @param node node selected
     *
     *  @return controller with the demo to show
     */
    public func demoViewController(with node: BlueSTSDKNode, menuManager: BlueSTSDKViewControllerMenuDelegate)
            -> UIViewController? {
                
        if(BlueSTSDKSTM32WBOTAUtils.isOTANode(node)){
            return BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: node,
                                                                      requireAddress: true,
                                                                      defaultAddress: BlueSTSDKSTM32WBOTAUtils.DEFAULT_FW_ADDRESS,
                                                                       requireFwType: true)
        }else if (BlueNRGOtaUtils.isOTANode(node)){
            return BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: node,
                                                                      requireAddress: false,
                                                                      defaultAddress:nil)
        }else{
            return getDemoViewController(with: node, menuManager: menuManager)
        }
        
    }
}


extension BlueMSMainViewController : BlueSTSDKAboutViewControllerDelegate{
    private static let PRIVACY_URL = URL(string:"http://www.st.com/content/st_com/en/common/privacy-policy.html")
    
    public func abaoutHtmlPagePath() -> String? {
        return Bundle.main.path(forResource: "text", ofType: "html");
    }
    
    public func headImage() -> UIImage? {
        return UIImage(named: "press_contact")
    }
    
    public func privacyInfoUrl() -> URL? {
        return BlueMSMainViewController.PRIVACY_URL
    }
    
    public func libLicenseInfo() -> [BlueSTSDKLibLicense]? {
        let bundle = Bundle.main;
        return [
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "AWSMobileSDK", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "BlueSTSDK", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "BlueSTSDK_Gui", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "CorePlot", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "IBMWatson", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "MBProgressHUD", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "MQTTClient", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "Reachability", ofType: "txt")!),
            BlueSTSDKLibLicense(licenseFile: bundle.path(forResource: "SwiftyJSON", ofType: "txt")!)
        ]
    }
    
}

extension BlueMSMainViewController : BlueSTSDKNodeListViewControllerDelegate{
    /**
     *  filter the node for show only the ones with remote features
     *
     *  @param node node to filter
     *
     */
    public func display(node: BlueSTSDKNode) -> Bool {
        return true;
    }
    
    public func prepareToConnect(node:BlueSTSDKNode){
        node.addExternalCharacteristics(BlueSTSDKStdCharToFeatureMap.getManageStdCharacteristics())
        node.addExternalCharacteristics(BlueSTSDKSTM32WBOTAUtils.getOtaCharacteristics())
        node.addExternalCharacteristics(BlueNRGOtaUtils.getOtaCharacteristics())
        if(STM32WBPeer2PeerDemoConfiguration.isValidDeviceNode(node)){
            node.addExternalCharacteristics(STM32WBPeer2PeerDemoConfiguration.getCharacteristicMapping())
        }
        if(node.type == .sensor_Tile_Box ){
            showStBoxPinAllert()
        }
        
    }
    
    private static let ST_BOX_PIN_ALLERT_SHOW = "BlueSTSDKNodeListViewControllerDelegate.ST_BOX_PIN_ALLERT_SHOW"
    
    private static let ST_BOX_PIN_ALLERT_TITLE:String = {
        let bundle = Bundle(for: BlueMSMotionIntensityViewController.self)
        return NSLocalizedString("SensorTile.Box Pin",
                                 tableName: nil,
                                 bundle: bundle,
                                 value: "SensorTile.Box Pin",
                                 comment: "")
        
    }();
    
    private static let ST_BOX_PIN_ALLERT_CONTENT:String = {
        let bundle = Bundle(for: BlueMSMotionIntensityViewController.self)
        return NSLocalizedString("If requested the default pin is 123456",
                                 tableName: nil,
                                 bundle: bundle,
                                 value: "If requested the default pin is 123456",
                                 comment: "")
        
    }();
    
    func showStBoxPinAllert(){
        let userSettings = UserDefaults.standard
        if(!userSettings.bool(forKey: Self.ST_BOX_PIN_ALLERT_SHOW )){
            showAllert(title: Self.ST_BOX_PIN_ALLERT_TITLE,
                       message: Self.ST_BOX_PIN_ALLERT_CONTENT)
            userSettings.set(true, forKey: Self.ST_BOX_PIN_ALLERT_SHOW)
        }
    }
    
    public var advertiseFilters: [BlueSTSDKAdvertiseFilter]{
        get{
            //if a board is compatible with multiple advertise, give the precedence to the sdk format
            return  BlueSTSDKManager.DEFAULT_ADVERTISE_FILTER + [ BlueNRGOtaAdvertiseParser() ]
        }
    }
}
