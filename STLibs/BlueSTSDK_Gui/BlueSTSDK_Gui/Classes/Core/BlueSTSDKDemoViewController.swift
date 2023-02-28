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
import MessageUI

public class BlueSTSDKDemoViewController: UIViewController{
    
    private static let START_LOG_ACTION: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Start Logging", tableName: nil,
                                 bundle: bundle,
                                 value: "Start Logging",
                                 comment: "Start Logging");
    }();
    
    private static let STOP_LOG_ACTION: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Stop Logging", tableName: nil,
                                 bundle: bundle,
                                 value: "Stop Logging",
                                 comment: "Stop Logging");
    }();
    
    private static let DEBUG_CONSOLE_ACTION: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Show Debug Console", tableName: nil,
                                 bundle: bundle,
                                 value: "Show Debug Console",
                                 comment: "Show Debug Console");
    }();
    
    private static let FW_UPGRADE_ACTION: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Firmware Upgrade", tableName: nil,
                                 bundle: bundle,
                                 value: "Firmware Upgrade",
                                 comment: "Firmware Upgrade");
    }();
    
    private static let CANCEL: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Cancel", tableName: nil,
                                 bundle: bundle,
                                 value: "Cancel",
                                 comment: "Cancel");
    }();
    
    private static let LOG_MAIL_TITLE_FORMAT: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("[ %@ ] Data Log", tableName: nil,
                                 bundle: bundle,
                                 value: "[ %@ ] Data Log",
                                 comment: "[ %@ ] Data Log");
    }();
    
    public var node:BlueSTSDKNode!
    public var demoViewController:UIViewController!
    @IBOutlet weak var demoView:UIView!
 
    public private(set) var isLogging:Bool = false
    private var mLogger:BlueSTSDKFeatureLogCSV? = nil
    private var mActions:[UIAlertAction] = []
    
    private var mActionDebug:UIAlertAction!
    private var mActionFwUpgradeManager:UIAlertAction!
    private var mActionStartLog:UIAlertAction!
    
    private var mActionStopLog:UIAlertAction!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mActionStopLog = UIAlertAction(title: BlueSTSDKDemoViewController.STOP_LOG_ACTION,
                                       style: .default){ _ in
                                        self.changeLoggingStatus() }
        
        mActionStartLog = UIAlertAction(title: BlueSTSDKDemoViewController.START_LOG_ACTION,
                                        style: .default){ _ in
                                            self.changeLoggingStatus()}
            
        mActionDebug = UIAlertAction(title: BlueSTSDKDemoViewController.DEBUG_CONSOLE_ACTION,
                                     style: .default){ _ in
                                        self.moveToDebugConsoleViewController() }
        
        mActionFwUpgradeManager = UIAlertAction(title: BlueSTSDKDemoViewController.FW_UPGRADE_ACTION,
                                                style: .default){ _ in
                                                    self.moveToFwUpgradeManagerViewController()}
        
        addMenuAction(mActionStartLog)
        addMenuAction(mActionDebug)
        addMenuAction(mActionFwUpgradeManager)
        let menuIcon = UIImage(named: "demo_menu_icon",
                               in: BlueSTSDK_Gui.bundle(),
                               compatibleWith: nil);
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: menuIcon, style: .plain, target: self,
                            action:#selector(showPopupMenu(_:)))
        
        displayContentController(self.demoViewController)
        
    }
    
    private func displayContentController(_ content:UIViewController){
        addChild(content)
        content.view.frame = self.demoView.bounds
        self.view.addSubview(content.view)
        content.didMove(toParent: self)
    }
   
    
    private func createMenuController() -> UIAlertController{
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        mActions.forEach{ alertController.addAction($0.copy() as! UIAlertAction)}
        
        if(UIDevice.current.userInterfaceIdiom == .phone){
            let cancel = UIAlertAction(title: BlueSTSDKDemoViewController.CANCEL, style: .cancel, handler: nil)
            alertController.addAction(cancel)
        }
        
        alertController.modalPresentationStyle = .popover
        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
            popoverController.permittedArrowDirections = []
        }
        
        return alertController
    }
 
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mLogger = BlueSTSDKFeatureLogCSV(timestamp: Date(), nodes: [self.node!])
        
        if(BlueSTSDKFwConsoleUtil.getFwUploadConsoleForNode(node: node)==nil){
            removeMenuAction(mActionFwUpgradeManager)
        }
        if(node.debugConsole==nil){
            removeMenuAction(mActionDebug)
        }
        node.addStatusDelegate(self)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        node.removeStatusDelegate(self)
    }
    
    private func sendLogToMail(){
        guard MFMailComposeViewController.canSendMail() else{
            return
        }
        
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate=self
        
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        mail.setSubject(String(format: BlueSTSDKDemoViewController.LOG_MAIL_TITLE_FORMAT, appName!))
        let files = BlueSTSDKFeatureLogCSV.getAllLogFiles()
        let fileManager = FileManager.default
        files?.forEach{ file in
            if let data = fileManager.contents(atPath: file.path){
                mail.addAttachmentData(data, mimeType: "text/plain", fileName: file.lastPathComponent)
            }
        }
        if(UIDevice.current.userInterfaceIdiom == .phone){
            navigationController?.present(mail, animated:true, completion: nil)
        }else{
            present(mail, animated: true, completion: nil)
        }
    }
    
    public static var logDirectoryPath:URL {
        get{
            return BlueSTSDKFeatureLogCSV.getDumpFileDirectoryUrl()
        }
    }
    
    public var logFilePrefix:String? {
        get {
            return mLogger?.sessionPrefix();
        }
    }
    
    private func startLogging(){
        guard let logger = mLogger else{
            return
        }
        node.getFeatures().forEach{ f in
            f.addLoggerDelegate(logger)
        }
        addMenuAction(mActionStopLog, atIndex: 0)
        removeMenuAction(mActionStartLog)
    }
    
    private func stopLogging(){
        guard let logger = mLogger else{
            return
        }
        node.getFeatures().forEach{ f in
            f.removeLoggerDelegate(logger)
        }
        addMenuAction(mActionStartLog, atIndex: 0)
        removeMenuAction(mActionStopLog)
        logger.closeFiles()
        sendLogToMail()
    }
   
    public func changeLoggingStatus(){
        if(isLogging){
            stopLogging()
        }else{
            startLogging()
        }
        isLogging = !isLogging
    }
    
    @objc public func showPopupMenu(_ sender:UIBarButtonItem){
        let alertController = createMenuController()
        if let popoverController = alertController.popoverPresentationController{
            popoverController.barButtonItem=sender
            popoverController.sourceView=self.view
        }
        present(alertController, animated: true, completion: nil)
    }
    
    private func moveToDebugConsoleViewController(){
        let storyBoard = UIStoryboard(name: "DebugConsoleMainView", bundle: BlueSTSDK_Gui.bundle())
        if let debugView = storyBoard.instantiateInitialViewController() as? BlueSTSDKDebugConsoleViewController{
            debugView.console = node.debugConsole
            changeViewController(debugView)
        }
    }
    
    private func moveToFwUpgradeManagerViewController(){
        let vc = BlueSTSDKFwUpgradeManagerViewController.instaziate(forNode: node, requireAddress: false)
        changeViewController(vc)
    }
    
}

extension BlueSTSDKDemoViewController:BlueSTSDKNodeStateDelegate{
    public func node(_ node: BlueSTSDKNode, didChange newState: BlueSTSDKNodeState, prevState: BlueSTSDKNodeState) {
        //if disconnect go back
        if(newState == .lost || newState == .unreachable || newState == .dead){
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}



extension BlueSTSDKDemoViewController:MFMailComposeViewControllerDelegate{
    private static let FAIL_TITLE: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Message Failed!", tableName: nil,
                                 bundle: bundle,
                                 value: "Message Failed!",
                                 comment: "Message Failed!");
    }();
    private static let FAIL_MSG: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Your email was not sent", tableName: nil,
                                 bundle: bundle,
                                 value: "Your email was not sent",
                                 comment: "Your email was not sent");
    }();
    private static let SENT_TITLE: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Message Sent", tableName: nil,
                                 bundle: bundle,
                                 value: "Message Sent",
                                 comment: "Message Sent");
    }();
    private static let SENT_MSG: String = {
        let bundle = BlueSTSDK_Gui.bundle()
        return NSLocalizedString("Your message has been sent.", tableName: nil,
                                 bundle: bundle,
                                 value: "Your message has been sent.",
                                 comment: "Your message has been sent.");
    }();


    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if(UIDevice.current.userInterfaceIdiom == .phone){
            navigationController?.dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true, completion: nil)
        }
        
        if(result == .failed){
            showAllert(title: BlueSTSDKDemoViewController.FAIL_TITLE,
                       message:BlueSTSDKDemoViewController.FAIL_MSG)
        }else if (result == .sent){
            showAllert(title: BlueSTSDKDemoViewController.SENT_TITLE,
                       message:BlueSTSDKDemoViewController.SENT_MSG)
            BlueSTSDKFeatureLogCSV.clearLogFolder()
        }
        
    }
}


 extension BlueSTSDKDemoViewController:BlueSTSDKViewControllerMenuDelegate{
    public func addBarButton(_ item: UIBarButtonItem) {
        navigationItem.rightBarButtonItems?.append(item)
    }
    
    public func removeBarButton(_ item: UIBarButtonItem) {
        if let index = navigationItem.rightBarButtonItems?.firstIndex(of: item){
            navigationItem.rightBarButtonItems?.remove(at: index)
        }
    }
    
    public func addMenuAction(_ action: UIAlertAction) {
        guard !mActions.contains(action) else{
            return;
        }
        mActions.append(action)
    }
    
    public func addMenuAction(_ action: UIAlertAction, atIndex index: Int) {
        removeMenuAction(action) // if present remove the old position 
        mActions.insert(action, at: index)
    
    }
    
    public func removeMenuAction(_ action: UIAlertAction) {
        if let index = mActions.firstIndex(of: action){
            mActions.remove(at: index)
        }
    }
    
    public var menuActionCount: Int {
        return mActions.count
    }
}
