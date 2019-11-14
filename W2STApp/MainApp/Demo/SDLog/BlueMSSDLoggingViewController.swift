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

public class BlueMSSDLoggingViewController: BlueMSDemoTabViewController, BlueMSSDLoggingView,
UITableViewDataSource,BlueMSSDLogFeatureTableCellViewSelectDelegate{
    
    
    private static let START_LOGGING_STR:String = {
        let bundle = Bundle(for: BlueMSSDLoggingViewController.self)
        return NSLocalizedString("Start Logging", tableName: nil, bundle: bundle,
                                 value: "Start Logging", comment: "")
    }();
    
    private static let STOP_LOGGING_STR:String = {
        let bundle = Bundle(for: BlueMSSDLoggingViewController.self)
        return NSLocalizedString("Stop Logging", tableName: nil, bundle: bundle,
                                 value: "Stop Logging", comment: "")
    }();

    private static let ERROR_NO_SD_STR:String = {
        let bundle = Bundle(for: BlueMSSDLoggingViewController.self)
        return NSLocalizedString("No SD available", tableName: nil, bundle: bundle,
                                 value: "No SD available", comment: "")
    }();
    
    private static let ERROR_IO_STR:String = {
        let bundle = Bundle(for: BlueMSSDLoggingViewController.self)
        return NSLocalizedString("SD IO Error", tableName: nil, bundle: bundle,
                                 value: "SD IO Error", comment: "")
    }();
    
    private static let DISABLED_DATA_WARNING_MSG:String = {
        let bundle = Bundle(for: BlueMSSDLoggingViewController.self)
        return NSLocalizedString("BLE sensor data not available while logging",
                                 tableName: nil, bundle: bundle,
                                 value: "BLE sensor data not available while logging",
                                 comment: "")
    }();
    private static let DISABLED_DATA_WARNING_TITLE:String = {
        let bundle = Bundle(for: BlueMSSDLoggingViewController.self)
        return NSLocalizedString("Warning",
                                 tableName: nil, bundle: bundle,
                                 value: "Warning",
                                 comment: "")
    }();
    
    private static let LOG_STARTED:String = {
        let bundle = Bundle(for: BlueMSSDLoggingViewController.self)
        return NSLocalizedString("Status: Recording the data",
                                 tableName: nil, bundle: bundle,
                                 value: "Status: Recording the data",
                                 comment: "")
    }();
    
    private static let LOG_STOPPED:String = {
        let bundle = Bundle(for: BlueMSSDLoggingViewController.self)
        return NSLocalizedString("Status: Press the button to start recording the data",
                                 tableName: nil, bundle: bundle,
                                 value: "Status: Press the button to start recording the data",
                                 comment: "")
    }();
    
    private static let CELL_REUSE_ID = "BlueMSSDLogTableViewCell"
    
    @IBOutlet weak var mStatusLabel: UILabel!
    @IBOutlet weak var mHoursValue: UITextField!
    @IBOutlet weak var mSecondsValue: UITextField!
    @IBOutlet weak var mMinutesValue: UITextField!
    @IBOutlet weak var mFeatureListTable: UITableView!
    @IBOutlet weak var mErrorLablel: UILabel!
    @IBOutlet weak var mLoggingIntervalView: UIView!
    
    @IBOutlet weak var mFeatureTableLabel: UILabel!
    @IBOutlet weak var mStartStopButton: UIButton!
    
    private var mPresenter:BlueMSSDLoggingPresenter!
    private var mAvailableFeatures:[BlueSTSDKFeature]?
    private var mSelectedFeatures = Set<BlueSTSDKFeature>()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        mFeatureListTable.dataSource = self
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        let logFeature = self.node.getFeatureOfType(BlueSTSDKFeatureSDLogging.self) as! BlueSTSDKFeatureSDLogging?;
        mPresenter = BlueMSSDLoggingPresenterImpl(self,logFeature)
        mPresenter.startDemo()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mPresenter.stopDemo()
    }

    /// hide the keyboard when the user touch something outside the UITextField
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = event?.allTouches?.first
        if( !(touch?.view?.isKind(of: UITextField.self) ?? false)){
            self.view.endEditing(true)
        }
        super .touchesBegan(touches, with: event)
    }
    
    public func setSelectedFeature(_ features: Set<BlueSTSDKFeature>) {
        mSelectedFeatures = features
        if mAvailableFeatures != nil {
            DispatchQueue.main.async {
                self.mFeatureListTable.reloadData();
                self.mStartStopButton.isEnabled = !self.mSelectedFeatures.isEmpty
            }
        }
    }
    
    public func getSelectedFeature() -> Set<BlueSTSDKFeature> {
        return mSelectedFeatures;
    }
    
    public func displayStartLoggingView(_ availableFeature: [BlueSTSDKFeature]?) {
        mAvailableFeatures = availableFeature;
        DispatchQueue.main.async {
            self.mStatusLabel.text = BlueMSSDLoggingViewController.LOG_STOPPED
            self.mStartStopButton.setTitle(BlueMSSDLoggingViewController.START_LOGGING_STR, for: .normal)
            let image = UIImage(imageLiteralResourceName: "sdLog_start")
            self.mStartStopButton.setImage(image, for: .normal)
            if(availableFeature != nil){
                self.mFeatureTableLabel.isHidden = false
                self.mFeatureListTable.isHidden = false
                self.mLoggingIntervalView.isHidden = false
                self.mFeatureListTable.reloadData()
            }else{
                self.mStartStopButton.isEnabled = true
            }
        }
    }
    
    public func displayStopLoggingView() {
        DispatchQueue.main.async {
            self.mStatusLabel.text = BlueMSSDLoggingViewController.LOG_STARTED
            self.mFeatureTableLabel.isHidden=true
            self.mFeatureListTable.isHidden=true
            self.mErrorLablel.isHidden=true
            self.mLoggingIntervalView.isHidden=true
            self.mStartStopButton.setTitle(BlueMSSDLoggingViewController.STOP_LOGGING_STR, for: .normal)
            let image = UIImage(imageLiteralResourceName: "sdLog_stop")
            self.mStartStopButton.setImage(image, for: .normal)
            self.mFeatureListTable.reloadData()
        }
    }
    
    private func changeInputViewStatus(enable:Bool){
        mHoursValue.isEnabled=enable
        mMinutesValue.isEnabled=enable
        mSecondsValue.isEnabled=enable
        mStartStopButton.isEnabled=enable
    }
    
    public func displayDisableLoggingView() {
        changeInputViewStatus(enable:false)
    }
    
    static func getNumberOr0(field:UITextField) -> UInt32{
        let value = field.text ?? "0"
        return UInt32(value) ?? 0
    }
    
    public func getLogInterval()->UInt32{
        let seconds = BlueMSSDLoggingViewController.getNumberOr0(field: mSecondsValue)
        let minute = BlueMSSDLoggingViewController.getNumberOr0(field: mMinutesValue)*60
        let hours = BlueMSSDLoggingViewController.getNumberOr0(field: mHoursValue)*60*60
        return seconds + minute + hours
    }
    
    public func setLogInterval(seconds: UInt32) {
        let sec = seconds % 60;
        let hours = seconds / (60*60)
        let minute = seconds/60-hours*60
        DispatchQueue.main.async {
            self.mSecondsValue.text = sec.description
            self.mMinutesValue.text = minute.description
            self.mHoursValue.text = hours.description
        }
    }
    
    public func displayIOErrorLoggingView() {
        displayErrorView(error: BlueMSSDLoggingViewController.ERROR_IO_STR)
        
    }
    
    public func displayNoSDCardErrorLoggingView() {
        displayErrorView(error: BlueMSSDLoggingViewController.ERROR_NO_SD_STR)
    }
    
    private func displayErrorView(error:String){
        DispatchQueue.main.async {
            self.displayStartLoggingView(self.mAvailableFeatures)
            self.mErrorLablel.text = error;
            self.mErrorLablel.isHidden=false;
        }
    }
    
    public func displayDisabledDataTransferWarning() {
        let dialog = UIAlertController(title: BlueMSSDLoggingViewController.DISABLED_DATA_WARNING_TITLE,
                                       message: BlueMSSDLoggingViewController.DISABLED_DATA_WARNING_MSG,
                                       preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .cancel)
        dialog.addAction(okButton)
        
        self.present(dialog, animated: true, completion: nil)
    }
    
    @IBAction func onStartStopLogPressed(_ sender: UIButton) {
        mPresenter.onStartStopLogPressed()
    }

    public func hideLogInterval() {
        DispatchQueue.main.async {
            self.mLoggingIntervalView.isHidden = true
        }
    }
    
    public func displayLogInterval() {
        DispatchQueue.main.async {
            self.mLoggingIntervalView.isHidden = false
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mAvailableFeatures?.count ?? 0;
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: BlueMSSDLoggingViewController.CELL_REUSE_ID);
        if (cell == nil){
            cell = BlueMSSDLogFeatureTableCellView(style: .default, reuseIdentifier:BlueMSSDLoggingViewController.CELL_REUSE_ID)
        }
        let featureCell = cell as! BlueMSSDLogFeatureTableCellView
        if let feature = mAvailableFeatures?[indexPath.row] {
            featureCell.setCellData(feature,mSelectedFeatures.contains(feature))
            featureCell.selectDelegate=self;
        }
        
        return featureCell
    }
    
    func onFeatureSelected(_ feature: BlueSTSDKFeature, _ selectState: Bool) {
        if(selectState){
            mSelectedFeatures.insert(feature)
        }else{
            mSelectedFeatures.remove(feature)
        }
        mStartStopButton.isEnabled = !mSelectedFeatures.isEmpty
    }
}

