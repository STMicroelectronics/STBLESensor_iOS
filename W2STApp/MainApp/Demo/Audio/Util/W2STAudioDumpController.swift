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
import MessageUI



public class W2STAudioDumpController : NSObject,MFMailComposeViewControllerDelegate {

    private static let MAIL_TITLE_FORMAT = "[%@] - Wave Audio";
    
    private let mMenuController : BlueSTSDKViewControllerMenuDelegate;
    private let mDateFormatter = DateFormatter()
    private let mParentViewController:UIViewController;
    private var startRecordingAction: UIAlertAction!;
    private var stopRecordingAction: UIAlertAction!;
    private var audioDump: W2STWaveFileDump?;
    private let mAudioConf:W2STAudioStreamConfig;

    public init(audioConf: W2STAudioStreamConfig, parentView: UIViewController,
                menuController:BlueSTSDKViewControllerMenuDelegate){
        mAudioConf=audioConf;
        
        mMenuController = menuController;
        mParentViewController = parentView;
        super.init();
        let bundle = Bundle(for: type(of: self));
        let startText = NSLocalizedString("Start Recording", tableName: nil,
                bundle: bundle,
                value: "Start Recording", comment: "Start Recording");

        let stopText = NSLocalizedString("Stop Recording", tableName: nil,
                bundle: bundle,
                value: "Stop Recording", comment: "Stop Recording");

        startRecordingAction = UIAlertAction(title: startText, style: .default) { action in self.startRecording() }
        stopRecordingAction = UIAlertAction(title: stopText, style: .default) { action in self.stopRecording() }

        mMenuController.addMenuAction(startRecordingAction);

    }

    public func viewWillDisappear(){
        if(audioDump != nil){
            stopRecording();
        }
        mMenuController.removeMenuAction(startRecordingAction);
    }

    private func startRecording() {
        audioDump = W2STWaveFileDump(audioParam:mAudioConf);
        if(audioDump != nil) {
            mMenuController.removeMenuAction(startRecordingAction);
            mMenuController.addMenuAction(stopRecordingAction);
        }
    }

    private func stopRecording() {
        if let dump = audioDump {
            dump.stopRecord();
            let mailView = composeMail(attach:dump.fileLocation);
            if let view = mailView{
                displayMailView(mailView: view);
            }
            mMenuController.removeMenuAction(stopRecordingAction);
            mMenuController.addMenuAction(startRecordingAction);
            audioDump=nil;
        }
    }

    private static func getMailSubject()->String{
        let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String
        return String(format: MAIL_TITLE_FORMAT, appName);
    }

    private func composeMail(attach:URL)-> MFMailComposeViewController?{
        let mail = MFMailComposeViewController();
        mail.setSubject(W2STAudioDumpController.getMailSubject());
        mail.mailComposeDelegate=self;
        let fileData = FileManager.default.contents(atPath: attach.path)
        if let data = fileData {
            mail.addAttachmentData(data, mimeType: "audio/wav", fileName: attach.lastPathComponent);
            return mail;
        }else{
            return nil;
        }
    }

    private func displayMailView(mailView: MFMailComposeViewController){
        if (UI_USER_INTERFACE_IDIOM() == .phone) {
            mParentViewController.navigationController?.present(mailView, animated: true);
        } else {
            mParentViewController.present(mailView, animated: true);
        }//if-else
    }

    private func hideMailView(){
        if (UI_USER_INTERFACE_IDIOM() == .phone) {
            mParentViewController.navigationController?.dismiss(animated: true);
        } else {
            mParentViewController.dismiss(animated: true)
        }//if-else
    }

    public func dumpAudioSample(sample:Data){
        if let dump = audioDump{
            dump.writeSample(sampleData: sample);
        }
    }

    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        hideMailView();
        if let audio = audioDump {
            do {
                //remove the file that we already send
                try FileManager.default.removeItem(at: audio.fileLocation)
            } catch {
            }
            audioDump=nil;
        }

    }



}
