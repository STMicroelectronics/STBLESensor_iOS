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
import BlueSTSDK_Gui

class BlueMSBatteryInfoViewController: BlueMSDemoTabViewController, UITableViewDataSource  {
    
    private static let COMMAND_TIMEOUT_S = TimeInterval(1.0);
    private static let COMMAND_BATTERY_INFO = "batteryinfo"
    private var mConsoleCommand:BlueMSConsoleCommand?;

    
    private static let NOT_AVAILABLE_DIALOG_TITLE:String = {
        let bundle = Bundle(for: BlueMSBatteryInfoViewController.self)
        return NSLocalizedString("Error", tableName: nil, bundle: bundle,
                                 value: "Error", comment: "")
    }();
    
    private static let NOT_AVAILABLE_DIALOG_MSG:String = {
        let bundle = Bundle(for: BlueMSBatteryInfoViewController.self)
        return NSLocalizedString("Battery info not available", tableName: nil, bundle: bundle,
                                 value: "Battery info not available", comment: "")
    }();
    
    private static let LOADING:String = {
        let bundle = Bundle(for: BlueMSBatteryInfoViewController.self)
        return NSLocalizedString("Loading...", tableName: nil, bundle: bundle,
                                 value: "Loading...", comment: "")
    }();
    
    @IBOutlet weak var mTitileLabel: UILabel!
    @IBOutlet weak var mErrorLabel: UILabel!
    @IBOutlet weak var mInfoTableView: UITableView!

    private var mBatteryInfo:[BlueMSBatteryInfo] = [] {
        didSet {
            DispatchQueue.main.async {
                self.mInfoTableView.reloadData();
            }
        }
    };

    override func viewDidLoad() {
        super.viewDidLoad();
        mInfoTableView.dataSource=self;
    }


    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true);
        guard self.node.debugConsole != nil else{
            infoNotAvailable();
            return;
        }
        mConsoleCommand = BlueMSConsoleCommand(self.node.debugConsole!, BlueMSBatteryInfoViewController.COMMAND_TIMEOUT_S);

        showWaitDialog();
        mConsoleCommand?.exec(BlueMSBatteryInfoViewController.COMMAND_BATTERY_INFO,
                onCommandResponds: self.onCommandResponds,
                onCommandError: self.onCommandError);

        mInfoTableView.reloadData();
    }
    
    private func infoNotAvailable(){
        self.showErrorMsg(BlueMSBatteryInfoViewController.NOT_AVAILABLE_DIALOG_MSG,
                          title:BlueMSBatteryInfoViewController.NOT_AVAILABLE_DIALOG_TITLE ,
                          closeController:true);
       // self.dismiss(animated: true);
    }
    
    private func showWaitDialog(){
        let progress = MBProgressHUD.showAdded(to: self.view, animated: true);

        progress.mode = .indeterminate;
        progress.label.text = BlueMSBatteryInfoViewController.LOADING;
    }

    private func hideWaitDialog(){
        MBProgressHUD.hide(for: self.view, animated: true);
    }

    
    @IBAction func onOkButtonClick(_ sender: Any) {
    
        dismiss(animated: true, completion: nil);
    
    }

   // private let mBatteryInfo:[BatteryInfo] = [];
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "W2STBatteryInfoCell", for: indexPath);
        let index = indexPath.row;
        
        cell.textLabel?.text = mBatteryInfo[index].title;
        cell.detailTextLabel?.text = mBatteryInfo[index].value;
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return mBatteryInfo.count;
    }

    private func onCommandResponds(_ response:String){
        print("resp:\(response)");
        mBatteryInfo = BlueMSBoardStatusBoardInfo.parse(response);
        DispatchQueue.main.async {
            self.hideWaitDialog();
            if(self.mBatteryInfo.count==0) {
                self.infoNotAvailable();
            }
        }
    }

    private func onCommandError(){
        DispatchQueue.main.async {
            self.hideWaitDialog();
            self.infoNotAvailable();
        }
    }



}
