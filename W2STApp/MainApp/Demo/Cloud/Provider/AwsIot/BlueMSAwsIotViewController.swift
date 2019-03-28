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

public class BlueMSAwsIotViewController : BlueMSCloudConfigDetailsViewController,
    UIDocumentPickerDelegate{
    private static let ENPOINT_KEY = "BlueMSAwsIotViewController_ENDPOINT"
    private static let CLIENT_KEY = "BlueMSAwsIotViewController_CLIENTID"
    private static let ENPOINT_FORMAT = "([-_\\w]*)\\.iot\\.([-_\\w]*)\\.amazonaws\\.com";
    
    private static let MISSING_DATA_TITLE:String = {
        let bundle = Bundle(for: BlueMSAwsIotViewController.self)
        return NSLocalizedString("Missing data", tableName: nil, bundle: bundle,
                                 value: "Missing data", comment: "")
    }();
    
    private static let MISSING_CERTIFICATE_FILE:String = {
        let bundle = Bundle(for: BlueMSAwsIotViewController.self)
        return NSLocalizedString("Missing certificate file", tableName: nil, bundle: bundle,
                                 value: "Missing certificate file", comment: "")
    }();
    
    private static let MISSING_PRIVATE_KEY_FILE:String = {
        let bundle = Bundle(for: BlueMSAwsIotViewController.self)
        return NSLocalizedString("Missing private key file", tableName: nil, bundle: bundle,
                                 value: "Missing private key file", comment: "")
    }();

    private static let INVALID_CLIENT_ID:String = {
        let bundle = Bundle(for: BlueMSAwsIotViewController.self)
        return NSLocalizedString("Invalid client Id", tableName: nil, bundle: bundle,
                                 value: "Invalid client Id", comment: "")
    }();
    
    private static let INVALID_ENDPOINT:String = {
        let bundle = Bundle(for: BlueMSAwsIotViewController.self)
        return NSLocalizedString("Invalid endpoint", tableName: nil, bundle: bundle,
                                 value: "Invalid endpoint", comment: "")
    }();
    
    @IBOutlet weak var mEndpointTextView: UITextField!
    @IBOutlet weak var mConnecitonIdTextView: UITextField!
    @IBOutlet weak var mSelectCertificateButton: UIButton!
    @IBOutlet weak var mSelectPrivateKeyButton: UIButton!
    
    
    private var mCertificateFile:URL?;
    private var mPrivateKeyFile:URL?;
    
    private var askForCertificateFile=false;
    private var askForPrivateKeyFile=false;
   
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        loadSettings()
    }
    
    private func loadSettings(){
        let configuration = UserDefaults.standard;
        mEndpointTextView.text = configuration.string(forKey:BlueMSAwsIotViewController.ENPOINT_FORMAT)
        mConnecitonIdTextView.text = configuration.string(forKey:BlueMSAwsIotViewController.CLIENT_KEY)
    }
    
    private func storeSettings(){
        let configuration = UserDefaults.standard;
        configuration.set(mEndpointTextView.text, forKey:BlueMSAwsIotViewController.ENPOINT_FORMAT)
        configuration.set(mConnecitonIdTextView.text, forKey:BlueMSAwsIotViewController.CLIENT_KEY)
    }

    private func buildSelectFileMenu(sourceView: UIView)-> UIDocumentPickerViewController{
        //"com.apple.keynote.key" = ask to open the keynote file to be able to download file with the key extension..
        let docMenu =  UIDocumentPickerViewController(documentTypes: ["public.data","com.apple.keynote.key"], in: .import);
        docMenu.delegate=self;
        docMenu.popoverPresentationController?.permittedArrowDirections = .up;
        docMenu.popoverPresentationController?.sourceView=sourceView;
        return docMenu;
    }
    
    
    @IBAction func onSelectPrivateKeyClick(_ sender: UIButton) {
        let docMenu = buildSelectFileMenu(sourceView: sender);
        askForCertificateFile=false;
        askForPrivateKeyFile=true;
        present(docMenu, animated: true, completion: nil);
    }
    
    private func onPrivateKeyFileSelected(url: URL){
        mPrivateKeyFile = url;
        mSelectPrivateKeyButton.setTitle(url.lastPathComponent, for: .normal)
    }
    
    private func isValidClientIdStr(_ clientId:String?) ->Bool{
        guard clientId != nil else {
            return false;
        }
        return !clientId!.isEmpty
    }
    
    private func isValidEndpointStr(_ endpoint:String?) -> Bool{
        guard endpoint != nil else {
            return false;
        }
        
        let validator = try? NSRegularExpression(pattern: BlueMSAwsIotViewController.ENPOINT_FORMAT,options: .caseInsensitive)
        
        let matchs = validator?.matches(in: endpoint!,
                                   options: [],
                                     range: NSRange(location: 0, length: endpoint!.count))
        if let matchs = matchs{
            return !matchs.isEmpty;
        }else{
            return false;
        }
    }
    
    private static func addHttpsPrefix(_ string:String) -> String{
        if(string.starts(with: "https://")){
            return string;
        }else if string.starts(with: "http://"){
            return string.replacingOccurrences(of: "http://", with: "https://")
        }else{
            return "https://"+string;
        }
    }
    
    public override func buildConnectionFactory() -> BlueMSCloudIotConnectionFactory?{
        let clientId = mConnecitonIdTextView.text;
        guard isValidClientIdStr(clientId) else {
            showAllert(title: BlueMSAwsIotViewController.MISSING_DATA_TITLE,
                       message:BlueMSAwsIotViewController.INVALID_CLIENT_ID)
            return nil;
        }
        let endpoint = mEndpointTextView.text;
        guard isValidEndpointStr(endpoint) else {
            showAllert( title: BlueMSAwsIotViewController.MISSING_DATA_TITLE,
                         message: BlueMSAwsIotViewController.INVALID_ENDPOINT)
            return nil;
        }
        guard mCertificateFile != nil else{
            showAllert( title: BlueMSAwsIotViewController.MISSING_DATA_TITLE,
                        message: BlueMSAwsIotViewController.MISSING_CERTIFICATE_FILE)
            return nil;
        }
        guard mPrivateKeyFile != nil else{
            showAllert( title: BlueMSAwsIotViewController.MISSING_DATA_TITLE,
                        message: BlueMSAwsIotViewController.MISSING_PRIVATE_KEY_FILE)
            return nil;
        }
        storeSettings()
        showDetailsButton()
        let httpsEndpoint = BlueMSAwsIotViewController.addHttpsPrefix(endpoint!);
        return BlueMSAwsIotConnectionFactory(endpointUrl: httpsEndpoint,deviceId: clientId!,certificate: mCertificateFile!,privateKey: mPrivateKeyFile!);
    }
    
    
    @IBAction func onSelectCertificateClick(_ sender: UIButton) {
        let docMenu = buildSelectFileMenu(sourceView: sender);
        askForCertificateFile=true;
        askForPrivateKeyFile=false;
        present(docMenu, animated: true, completion: nil);
    }
    
    private func onCertificateFileSelected(url: URL){
        mCertificateFile = url;
        mSelectCertificateButton.setTitle(url.lastPathComponent, for: .normal)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL){
        if(askForCertificateFile){
            onCertificateFileSelected(url: url)
        }else if(askForPrivateKeyFile){
            onPrivateKeyFileSelected(url: url)
        }
    }
    
}
