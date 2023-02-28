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

public protocol BlueSTSDKMainViewControllerDelegate {

    
    /// method called when the start scanning button is pressed,
    /// optional method, the default implementation will just return true
    ///
    /// - Parameter currentViewController: view controller that contains the button
    /// - Returns: true if you need that the default action will be done -> move to the NodeListViewController
    func onStartDiscoverClicked(currentViewController:UIViewController)->Bool;
    
    
    /// method called when the About button in pressed
    /// optional method, the default implementation will just return true
    ///
    /// - Parameter currentViewController: view controller that contains the button
    /// - Returns: true if you need that the default action will be done -> move to the AboutViewController
    func onAboutClicked(currentViewController:UIViewController)->Bool;
}

extension BlueSTSDKMainViewControllerDelegate {
    
    /// method called when the start scanning button is pressed
    /// default implementation, it just return true to trigger the default action
    ///
    /// - Parameter currentViewController: view controller that contains the button
    /// - Returns: it just return true to trigger the default action
    func onStartDiscoverClicked(currentViewController:UIViewController)->Bool{
        return true;
    }


    /// method called when the About button in pressed
    /// default implementation, it just return true to trigger the default action
    ///
    /// - Parameter currentViewController: view controller that contains the button
    /// - Returns: true if you need that the default action will be done -> move to the AboutViewController
    func onAboutClicked(currentViewController:UIViewController)->Bool{
        return true;
    }

}

open class BlueSTSDKMainViewController: UIViewController {

    private static let PRIVACY_DIALOG_SHOWN = "BlueSTSDKMainViewController.PrivacyDialogShown";
    private static let ABOUT_VIEWCONTROLLER_ID = "AboutViewController";
    private static let SHOW_NODE_LIST_VIEWCONTROLLER_ID = "NodeListViewController";

    @IBOutlet open weak var mAppNameLabel: UILabel!
    @IBOutlet open weak var mAppVersionLabel: UILabel!
    
    @IBOutlet open weak var mAboutButton: UIButton!
    @IBOutlet open weak var mNodeListButton: UIButton!


    public var delegateAbout:BlueSTSDKAboutViewControllerDelegate?=nil;
    public var delegateMain: BlueSTSDKMainViewControllerDelegate?=nil;
    public var delegateNodeList:BlueSTSDKNodeListViewControllerDelegate?=nil;

    private func displayAppNameInfo(){
        let appBudle = Bundle.main;
        let version = appBudle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String;
        let appName = appBudle.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String;
        mAppNameLabel.text = appName;
        mAppVersionLabel.text?.append(version);
    }
    
    override open func viewDidLoad(){
        super.viewDidLoad();

        displayAppNameInfo()
    }

    /**
    *  Hide the navigation bar for keep space for the search button in small devices
    *
    *  @param animated true if the system is doing an animation
    */
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden=true;
        if(needPrivacyDialog()){
            displayPrivacyDialog()
        }
    }


    /**
    *  Show the navigation bar for the next view
    *
    * @param animated true if the system is doing an animation
    */
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden=false;
    }

    @IBAction open func onAboutClick(_ sender: UIButton) {
        if(delegateMain != nil && !delegateMain!.onAboutClicked(currentViewController: self)) {
            return;
        }else{
            showAboutViewController()
        }
    }
    
    private func loadViewController(withIdentifier id:String) -> UIViewController{
        let storyboard = UIStoryboard(name: "BlueSTSDKMainView", bundle: BlueSTSDK_Gui.bundle())
        
        return storyboard.instantiateViewController(withIdentifier: id)
    }

    private func showAboutViewController(){
        
        let aboutView = loadViewController(withIdentifier: BlueSTSDKMainViewController.ABOUT_VIEWCONTROLLER_ID) as? BlueSTSDKAboutViewController
        
        aboutView?.delegate = delegateAbout
        if let vc = aboutView {
            changeViewController(vc)
        }
        
    }
    
    private func showNodeListViewController(){
        
        let nodeListView = loadViewController(withIdentifier: BlueSTSDKMainViewController.SHOW_NODE_LIST_VIEWCONTROLLER_ID)
            as? BlueSTSDKNodeListViewController
        
        nodeListView?.delegate = delegateNodeList
        if let vc = nodeListView {
            changeViewController(vc)
        }
    }
    
    @IBAction open func onStartDiscoveryClick(_ sender: UIButton) {
        if(delegateMain != nil && !delegateMain!.onStartDiscoverClicked(currentViewController: self)) {
            return;
        }else{
            showNodeListViewController()
        }
    }
    
   
    private func displayPrivacyDialog(){
        let bundle = Bundle(for: type(of: self));

        let title = NSLocalizedString("Privacy Policy", tableName: nil,
                                     bundle: bundle,
                                     value: "Privacy Policy", comment: "Privacy Policy");
        let message = NSLocalizedString("Open the link to show the app privacy policy",
                                        tableName: nil, bundle: bundle,
                                      value: "Open the link to show the app privacy policy",
                                      comment: "Open the link to show the app privacy policy");
        
        let dialog = UIAlertController(title: title,
                                       message: message,
                                       preferredStyle: .alert);
        
        let okButton = UIAlertAction(title: "Ok", style: .cancel) { (dialog) in
            UserDefaults.standard.set(true, forKey: BlueSTSDKMainViewController.PRIVACY_DIALOG_SHOWN)
            UserDefaults.standard.synchronize();
        };
        
        let showPrivacyLink = UIAlertAction(title: title, style: .default) { (dialog) in
            if let privacyUrl = self.delegateAbout?.privacyInfoUrl() {
                UIApplication.shared.open(privacyUrl)
            }
            UserDefaults.standard.set(true, forKey: BlueSTSDKMainViewController.PRIVACY_DIALOG_SHOWN)
            UserDefaults.standard.synchronize();
        };
        
        dialog.addAction(okButton);
        dialog.addAction(showPrivacyLink);
        
        self.present(dialog, animated: true, completion: nil);
        
    }
    
    private func privacyDialogWasShow() -> Bool{
        return UserDefaults.standard.bool(forKey: BlueSTSDKMainViewController.PRIVACY_DIALOG_SHOWN);
    }
    
    private func needPrivacyDialog() -> Bool{
        return self.delegateAbout?.privacyInfoUrl() != nil && !privacyDialogWasShow()
    }
    

}
