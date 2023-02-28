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
import BlueSTSDK

public class BlueSTSDKDebugConsoleViewController : UIViewController{

    private static let PAUSE_DETECTION_TIME:TimeInterval = 0.1 //ms
    private static let MAX_MESSAGE_LENGTH_BYTE = 20
    private typealias TextColorAtt_t = [NSAttributedString.Key : UIColor]
    
    private static let GENERIC_TEXT_ATT:[NSAttributedString.Key : UIColor] = {
        if #available(iOS 13, *) {
            return [NSAttributedString.Key.foregroundColor : UIColor.label]
        }else{
            return [NSAttributedString.Key.foregroundColor : UIColor.black]
        }
    }()
    
    private static let ERROR_TEXT_ATT = [
        NSAttributedString.Key.foregroundColor : UIColor.red
    ]
    
    private static let OUT_TEXT_ATT = [
        NSAttributedString.Key.foregroundColor : UIColor.blue
    ]
    
    
    private static let IN_TEXT_ATT:[NSAttributedString.Key : UIColor] = {
        if #available(iOS 13, *) {
            return [NSAttributedString.Key.foregroundColor : UIColor.label]
        }else{
            return [NSAttributedString.Key.foregroundColor : UIColor.black]
        }
    }()
    
    private static let CANCEL:String = {
        let bundle = Bundle(for: BlueSTSDKDebugConsoleViewController.self);
        return NSLocalizedString("Cancel", tableName: nil,
                                 bundle: bundle,
                                 value: "Cancel",
                                 comment: "Cancel");
    }();

    private static let SEND_HELP:String = {
        let bundle = Bundle(for: BlueSTSDKDebugConsoleViewController.self);
        return NSLocalizedString("Send Help", tableName: nil,
                                 bundle: bundle,
                                 value: "Send Help",
                                 comment: "Send Help");
    }();
    
    private static let SHOW_HELP:String = {
        let bundle = Bundle(for: BlueSTSDKDebugConsoleViewController.self);
        return NSLocalizedString("Send 'help' for help", tableName: nil,
                                 bundle: bundle,
                                 value: "Send 'help' for help",
                                 comment: "Send 'help' for help");
    }();
    
    private static let HIDE_KEYBOARD:String = {
        let bundle = Bundle(for: BlueSTSDKDebugConsoleViewController.self);
        return NSLocalizedString("Hide keyboard", tableName: nil,
                                 bundle: bundle,
                                 value: "Hide keyboard",
                                 comment: "Hide keyboard");
    }();
    
    private static let CLEAN_CONSOLE:String = {
        let bundle = Bundle(for: BlueSTSDKDebugConsoleViewController.self);
        return NSLocalizedString("Clean", tableName: nil,
                                 bundle: bundle,
                                 value: "Clean",
                                 comment: "Clean");
    }();
    
    private static let HELP_COMMAND:String = "help\n"
    
    private static let DATE_FORMATTER:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .medium
        dateFormatter.dateStyle = .medium
        return dateFormatter
    }()
    
    @IBOutlet weak var mMenuButton: UIBarButtonItem!
    @IBOutlet weak var mConsoleView: UITextView!
    @IBOutlet weak var mInputText: UITextField!
    
    private enum MessageType{
        case error
        case input
        case output
        case generic
    }
    
    private static func getAttributedString(str:String, type:MessageType) ->NSAttributedString{
        let attribute:TextColorAtt_t = { type in
            switch type {
            case .error:
                return BlueSTSDKDebugConsoleViewController.ERROR_TEXT_ATT
            case .input:
                return BlueSTSDKDebugConsoleViewController.OUT_TEXT_ATT
            case .output:
                return BlueSTSDKDebugConsoleViewController.IN_TEXT_ATT
            case .generic:
                return  BlueSTSDKDebugConsoleViewController.GENERIC_TEXT_ATT
            }
        }(type)
        return NSAttributedString(string: str, attributes: attribute)
    }
    
    
    
    @objc public var console:BlueSTSDKDebug!

    private var mDisplayString:NSMutableAttributedString = NSMutableAttributedString()
    private var mToSendMessage:String? = nil
    private var mNextPartToSend:Int = -1
    private var mWaitEcho = true
    private var mKeyboardIsShown=false;
    private var mLastMessageReceived = Date(timeIntervalSince1970: 0)
    private var mLastMessageSent = Date(timeIntervalSince1970: 0)
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = mMenuButton
        self.appendMessage(message: BlueSTSDKDebugConsoleViewController.SHOW_HELP, type: .generic,addReturn: true,showTime: false)
        mInputText.delegate=self
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mInputText.becomeFirstResponder()
        console.add(self)
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        console.remove(self)
    }
    
    private func buildTime()->String{
        let fromLastMessage = -mLastMessageReceived.timeIntervalSinceNow
        if(fromLastMessage>BlueSTSDKDebugConsoleViewController.PAUSE_DETECTION_TIME){
            return BlueSTSDKDebugConsoleViewController.DATE_FORMATTER.string(from: Date())
        }else{
            return ""
        }
    }
    
    private func appendMessage(message:String,type:MessageType,addReturn:Bool, showTime:Bool){
        var showString = showTime ? buildTime() : ""
        if(showString.count != 0){ // if we append some time
            showString.append(": ")
        }
        showString.append(message)
        showString.append(addReturn ? "\n" : "")
        let attString = BlueSTSDKDebugConsoleViewController.getAttributedString(str:showString,type:type)
        appendDisplayMessage(attString)
        mLastMessageReceived = Date()
    }
    
    private func resetDisplayedString(){
        DispatchQueue.main.async {
            self.mDisplayString = NSMutableAttributedString()
            self.mConsoleView.attributedText = nil
            self.scrollToEnd()
        }
    }
    
    private func appendDisplayMessage(_ message:NSAttributedString){
        DispatchQueue.main.async {
            self.mDisplayString.append(message)
            self.mConsoleView.attributedText = self.mDisplayString
            self.scrollToEnd()
        }
    }
    
    private func scrollToEnd(){
        let origRange = mConsoleView.selectedRange
        let editable = mConsoleView.isEditable
        
        if(mConsoleView.isScrollEnabled){
            if(mConsoleView.text.count > 0){
                let bottom = NSMakeRange(mConsoleView.text.count, 1)
                mConsoleView.scrollRangeToVisible(bottom)
                //needed for a smoth scrolling
                mConsoleView.isScrollEnabled=false;
                mConsoleView.isScrollEnabled=true;
            }
        }
        mConsoleView.selectedRange = origRange
        mConsoleView.isEditable=editable
    }
    
    private func resetMessageToSend(){
        mToSendMessage = nil;
        mNextPartToSend = -1;
    }
    
    private func getSubStringToSend(package:Int)->String?{
        let startIndex = package*BlueSTSDKDebugConsoleViewController.MAX_MESSAGE_LENGTH_BYTE
        
        if let toSend = mToSendMessage, startIndex<toSend.count{
            let lenToSend = toSend.count - startIndex
            let len = min(BlueSTSDKDebugConsoleViewController.MAX_MESSAGE_LENGTH_BYTE,lenToSend)
            
            let startStrIndex = toSend.index(toSend.startIndex, offsetBy: startIndex)
            let stopStrIndex = toSend.index(startStrIndex, offsetBy: len)
            return String(toSend[startStrIndex..<stopStrIndex])
        }
        return nil
    }
    
    private func writeNextMessage() -> Bool{
        if let message = getSubStringToSend(package: mNextPartToSend){
            mNextPartToSend = mNextPartToSend + 1
            return console.writeMessage(message) == message.count
        }
        return false;
    }
    
    private func sendMessage(_ message:String, addReturn:Bool)->Bool{
        var ret = false
        
        let elapsedMillisec = -mLastMessageSent.timeIntervalSinceNow
        if( mToSendMessage == nil || elapsedMillisec > BlueSTSDKDebugConsoleViewController.PAUSE_DETECTION_TIME){
            ret = true;
            resetMessageToSend()
            if(message.count != 0){
                mToSendMessage = addReturn ? message+"\n" : message
                mNextPartToSend = 0
                ret = writeNextMessage();
                mLastMessageSent = Date();
            }
        }
        return ret;
    }
    
    private func updateDisplayString(){
        
    }
    
    private func buildSendHelpMenuItem()->UIAlertAction{
        return UIAlertAction(title: BlueSTSDKDebugConsoleViewController.SHOW_HELP, style: .default){ _ in
            _ = self.sendMessage(BlueSTSDKDebugConsoleViewController.HELP_COMMAND, addReturn: false)
        }
    }
    
    private func hideKeyboardMenuItem() -> UIAlertAction{
        return UIAlertAction(title: BlueSTSDKDebugConsoleViewController.HIDE_KEYBOARD, style: .default){ _ in
            //self.mInputText.endEditing(true)
            self.view.endEditing(true)
        }
    }
    
    private func buildCleanConsoleMenuItem() -> UIAlertAction{
        return UIAlertAction(title: BlueSTSDKDebugConsoleViewController.CLEAN_CONSOLE, style: .default){ _ in
            self.resetDisplayedString()
        }
    }
    
    
    @IBAction func onMenuButtonClicked(_ sender: UIBarButtonItem) {
        let menuController = UIAlertController(title: nil, message: nil,
                                               preferredStyle: .actionSheet);
        menuController.addAction(buildSendHelpMenuItem())
        menuController.addAction(hideKeyboardMenuItem())
        menuController.addAction(buildCleanConsoleMenuItem())
        if(UIDevice.current.userInterfaceIdiom == .phone){
            menuController.addAction(UIAlertAction(title: BlueSTSDKDebugConsoleViewController.CANCEL, style: .cancel, handler: nil))
        }
        
        menuController.modalPresentationStyle = .popover
        if let popController = menuController.popoverPresentationController{
            popController.barButtonItem=sender
            popController.sourceView=self.view
        }
        present(menuController, animated: true, completion: nil)
    }
    
    private func changeConsoleHeightBy(delta:CGFloat){
        var currentViewFrame = self.view.frame
        currentViewFrame.size.height = currentViewFrame.size.height + delta
        
        self.view.frame = currentViewFrame
    }
    
    private func getKeyboardHeight( notificationData:NSNotification) -> CGFloat{
        let userInfo = notificationData.userInfo;
        let keyBoardSizeValue = (userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)
        let keyBoardSize = keyBoardSizeValue?.cgRectValue.size ?? CGSize(width: 0, height: 0)
        return keyBoardSize.height
    }
    
    @objc public func resizeConsoleOnKeyboardShow(_ n:NSNotification){
        guard mKeyboardIsShown == false else {
            return;
        }
        let keyboardHeight = getKeyboardHeight(notificationData: n)
        changeConsoleHeightBy(delta:-keyboardHeight)
        mKeyboardIsShown = true
    }
 
    @objc public func resizeConsoleOnKeyboardHide(_ n:NSNotification){
        guard mKeyboardIsShown == true else {
            return;
        }
        
        let keyboardHeight = getKeyboardHeight(notificationData: n)
        changeConsoleHeightBy(delta: keyboardHeight)
        mKeyboardIsShown = false
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resizeConsoleOnKeyboardShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: self.view.window)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(resizeConsoleOnKeyboardHide(_:)),
                                               name:UIResponder.keyboardDidHideNotification,
                                               object: self.view.window)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self,
                                                  name:UIResponder.keyboardWillShowNotification,
                                                  object: self.view.window)
        NotificationCenter.default.removeObserver(self,
                                                  name:UIResponder.keyboardWillHideNotification,
                                                  object: self.view.window)
    }
    
}

extension BlueSTSDKDebugConsoleViewController : BlueSTSDKDebugOutputDelegate{
    public func debug(_ debug: BlueSTSDKDebug, didStdOutReceived msg: String) {
        appendMessage(message: msg, type: .output, addReturn: false, showTime: true)
        if let message = getSubStringToSend(package: mNextPartToSend-1),
            message == msg && mWaitEcho {
            if(!writeNextMessage()){
                resetMessageToSend()
            }
        }
    }
    
    public func debug(_ debug: BlueSTSDKDebug, didStdErrReceived msg: String) {
        appendMessage(message: msg, type: .error, addReturn: false, showTime: true)
    }
    
    public func debug(_ debug: BlueSTSDKDebug, didStdInSend msg: String, error: Error?) {
        if(mWaitEcho){
            if(mNextPartToSend==1 && mToSendMessage != nil){
                appendMessage(message: mToSendMessage!,
                              type: .input,
                              addReturn: false,
                              showTime: true)
            }
        }else{
            appendMessage(message: msg,
                          type: .input,
                          addReturn: false,
                          showTime: true)
        }//if-else
    }//
}

extension BlueSTSDKDebugConsoleViewController : UITextFieldDelegate{
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if let text = textField.text{
            if(sendMessage(text, addReturn: true)){
                textField.text=nil
                return true
            }
        }
        return false
    }
}
