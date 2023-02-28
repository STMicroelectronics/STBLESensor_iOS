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
import UIKit


/// Class that contains the license name and the path with the library license file
public class BlueSTSDKLibLicense : NSObject{
    
    
    /// Extract the file name from a path string
    ///
    /// - Parameter path: file path
    /// - Returns: file name without the extension and path, it can return just the file name if the url creation fails
    private static func extratFileName(path:String)->String{
        if let fileNameWithoutExtension = NSURL(fileURLWithPath: path).deletingPathExtension?.lastPathComponent {
            return fileNameWithoutExtension
        } else {
            return (path as NSString).lastPathComponent
        }
    }
    
    /// Library name
    public let libName:String;
    
    /// Path where find the library license
    public let libLicensePath:String;
    
    
    /// create an object
    ///
    /// - Parameters:
    ///   - name: library name
    ///   - licenseFile: license location
    @objc public init(name:String , licenseFile:String){
        libName=name;
        libLicensePath = licenseFile;
    }
    
    
    /// create an object, the license name is the file name that contains the licenses
    ///
    /// - Parameter licenseFile: path with the license
    @objc public init(licenseFile:String){
        libName = BlueSTSDKLibLicense.extratFileName(path: licenseFile);
        libLicensePath = licenseFile;
    }
    
}

@objc public protocol BlueSTSDKAboutViewControllerDelegate{
    
    /// page to show as main content of the page
    ///
    /// - Returns: path of an html file or nil if not needed
    func abaoutHtmlPagePath() -> String?;
    
    
    /// image to show on the top of the view
    ///
    /// - Returns: image to show on the top or nil if not needed
    func headImage() -> UIImage?;

    
    /// display the menu with the privacy information
    ///
    /// - Returns: url where fine the privacy information
    func privacyInfoUrl()->URL?;
    
    
    /// display the menu with the license of the third party
    ///
    /// - Returns: list of infos about the third party libraries, nil if not needed
    func libLicenseInfo()->[BlueSTSDKLibLicense]?

}

/// default implementation of the delegate
extension BlueSTSDKAboutViewControllerDelegate {

    
    /// default implementation returning nil
    ///
    /// - Returns: nil
    func abaoutHtmlPagePath() -> String?{
        return nil;
    }


    /// default implementation returning nil
    ///
    /// - Returns: nil
    func headImage() -> UIImage?{
        return nil;
    }

    /// default implementation returning nil
    ///
    /// - Returns: nil
    func privacyInfoUrl()->URL?{
        return nil;
    }

    /// default implementation returning nil
    ///
    /// - Returns: nil
    func libLicenseInfo()->[BlueSTSDKLibLicense]?{
        return nil;
    }

}

@objc public class BlueSTSDKAboutViewController : UIViewController , UIWebViewDelegate{

    /// Segue to see the third party license information
    private static let LICENSES_VIEW_CONTROLLER_SEGUE = "bluestsdk_show_lib_licenses";

    @IBOutlet weak var mAppVersionLabel: UILabel!
    @IBOutlet weak var mAppNameLabel: UILabel!
    @IBOutlet weak var mWebView: UIWebView!
    @IBOutlet weak var mHeadImage: UIImageView!
    
    @IBOutlet weak var mDetailsMenu: UIBarButtonItem!

    private var mDetailsMenuController : UIAlertController!;
    
    
    /// When the button in selected, show the menu
    @IBAction func onDetailsMenuClick(_ sender: UIBarButtonItem) {

        guard mDetailsMenuController != nil else{
            return;
        }

        let presenter = mDetailsMenuController?.popoverPresentationController;
        presenter?.barButtonItem=sender;
        presenter?.sourceView=self.view;

        present(mDetailsMenuController!, animated: true)
    }
    
    
    public var delegate:BlueSTSDKAboutViewControllerDelegate? = nil;
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setUpAppDetails();
        setUpAboutDetails();
        setUpHeadImage();
        setUpDetailMenu();
    }


    /// Display app name and version
    private func setUpAppDetails(){
        let bundle = Bundle.main;
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String;
        let appName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String;
        mAppNameLabel.text = appName;
        mAppVersionLabel.text=version;
    }

    
    /// tell if the menu icon is necessary or not
    ///
    /// - Returns: true if we have to display the menu
    private func needDetailsMenu() -> Bool{
        return delegate?.privacyInfoUrl() != nil || delegate?.libLicenseInfo() != nil;
    }
    
    
    /// if needed create the menu to display to show the privacy and licenses
    private func setUpDetailMenu() {

        guard needDetailsMenu() else {
            return;
        }
        
        navigationItem.rightBarButtonItem = mDetailsMenu;

        mDetailsMenuController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);

        let bundle = Bundle(for: type(of: self));

        //create the privacy policy item
        let privacyUrl = delegate?.privacyInfoUrl()
        if( privacyUrl != nil){
            let privacyText = NSLocalizedString("Privacy Policy", tableName: nil,
                    bundle: bundle,
                    value: "Privacy Policy", comment: "Privacy Policy");

            let privacyAction = UIAlertAction(title: privacyText, style: .default) { action in
                UIApplication.shared.open(privacyUrl!);
             }
            mDetailsMenuController.addAction(privacyAction);
        }

        
        //create the license items
        let libLicenseInfos = delegate?.libLicenseInfo();
        if(libLicenseInfos != nil){
            let licenseText = NSLocalizedString("Licenses", tableName: nil,
                    bundle: bundle,
                    value: "Licenses", comment: "Licenses");

            let privacyAction = UIAlertAction(title: licenseText, style: .default) { action in
                self.performSegue(withIdentifier: BlueSTSDKAboutViewController.LICENSES_VIEW_CONTROLLER_SEGUE,
                        sender: action);
            }
            mDetailsMenuController.addAction(privacyAction);
        }


        //create the cancel item if it is an iphone
        if(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiom.pad){
            let cencelText = NSLocalizedString("Cancel", tableName: nil,
                    bundle: bundle,
                    value: "Cancel", comment: "Cancel");
            let cancelAction = UIAlertAction(title: cencelText, style: .cancel);
            mDetailsMenuController.addAction(cancelAction);
        }

        mDetailsMenuController.modalPresentationStyle = .popover;
    }


    /// diplay the top image if needed
    private func setUpHeadImage() {
        let image = delegate?.headImage();
        if let img = image {
            mHeadImage.image = img;
        }
    }

    
    /// display the main page if needed
    private func setUpAboutDetails() {
        if let del = delegate {
            let webPageUri = del.abaoutHtmlPagePath();
            if(webPageUri == nil) {
                return;
            }
            mWebView.delegate=self;
            do{
                let pageContent = try String(contentsOfFile: webPageUri!, encoding: .utf8)
                mWebView.loadHTMLString(pageContent, baseURL: nil);
                mWebView.scrollView.isScrollEnabled=false;
                mWebView.scrollView.bounces=false;
            } catch {
                print("BlueSTSDKAboutViewController: Impossible open \(webPageUri!)");
            }//do - catch
        }//if
    }// setUpAboutDetails
    
    /// if a link is pressed open the broweser to display it
    ///
    /// - Parameters:
    ///   - webView: <#webView description#>
    ///   - request: <#request description#>
    ///   - navigationType: <#navigationType description#>
    /// - Returns: <#return value description#>
    public func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebView.NavigationType) -> Bool {
        if ( navigationType == UIWebView.NavigationType.linkClicked){
            UIApplication.shared.open(request.url!)
            return false;
        }
        return true;
    }

    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if(segue.identifier == BlueSTSDKAboutViewController.LICENSES_VIEW_CONTROLLER_SEGUE){
            let destinationController = segue.destination as! BlueSTSDKLibLicenseViewController;
            destinationController.licensePath = delegate?.libLicenseInfo();
        }
    }


}
