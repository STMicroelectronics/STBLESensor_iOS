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

/// view controller that manage a button to start the magnetometer calibration
/// and show a dialog when it start
public class BlueMSCalibrationViewController : BlueMSDemoTabViewController,
    BlueSTSDKFeatureAutoConfigurableDelegate{
    
    /// view where display the dialog message
    @IBOutlet weak var mDialogViewPlaceHolder: UIView!
    
    /// button that triggers the calibration
    @IBOutlet weak var mCalibButton: UIButton!

    /// segue that will display the calibration message
    private static let SHOW_CALIBRATION_SEGUE = "ResetCalibDialogID"

    /// image to use when the magnetometer is calibrated
    private static let CALIB_IMAGE = UIImage(named: "calibrated.png");
    /// image to use when the magnetometer is not calibrated
    private static let UN_CALIB_IMAGE = UIImage(named: "uncalibrated.png");
    
    /// view controller that show the calibration message
    private var mCalibDialog: BlueMSSimpleDialogViewController?;
    
    /// feature that will be calibrated
    private var featureToCalibrate:BlueSTSDKFeatureAutoConfigurable?
    
    func manageCalibrationForFeature(_ feature:BlueSTSDKFeatureAutoConfigurable?){
        
        //remove the listener from the old feature
        if let feature = featureToCalibrate{
            feature.removeFeatureConfigurationDelegate(self);
        }
        
        featureToCalibrate = feature;
        
        // set the listener for the new feature
        if let feature = feature{
            feature.addFeatureConfigurationDelegate(self)
            setCalibrationState(feature.isConfigured);
        }
    }
    
    /// set the view to show the calibration state
    private func setCalibrationState(_ isCalibrated:Bool){
        setCalibrationButtonState(isCalibrated);
        if(!isCalibrated && self.node.type != .STEVAL_WESU1){
            onCalibPressed(); //start the calibration if not already calibrated
        }
    }
    
    // start the calibration process
    @IBAction func onCalibrationButtonClicked(_ sender: UIButton) {
        onCalibPressed()
    }
    
    //remove the listener when the view disappear
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        if let feature = featureToCalibrate {
            feature.removeFeatureConfigurationDelegate(self);
        }
    }
    
    //change the button image
    private func setCalibrationButtonState(_ status:Bool){
        if(status){
            mCalibButton.imageView?.image = BlueMSCalibrationViewController.CALIB_IMAGE;
        }else{
            mCalibButton.imageView?.image = BlueMSCalibrationViewController.UN_CALIB_IMAGE;
        }
    }
    
    //callback call when the node change its calibration status
    public func didAutoConfigurationChange(_ feature: BlueSTSDKFeatureAutoConfigurable!, status: Int32){
        
        DispatchQueue.main.async {
            self.setCalibrationButtonState(feature.isConfigured);
            if(feature.isConfigured){
                self.onCalibComplete()
            }//if calib
        } // main async
        
    }
    
    //start the calibration and show the dialog
    private func onCalibPressed(){
        featureToCalibrate?.startAutoConfiguration()
        onCalibStart()
    }
    
    /// display the calib dialog
    func onCalibStart(){
        self.performSegue(withIdentifier: BlueMSCalibrationViewController.SHOW_CALIBRATION_SEGUE, sender: self)
    }
    
    //remove the calib dialog
    func onCalibComplete(){
        mCalibDialog?.dismiss();
        mCalibDialog=nil;
    }
    
    /// display the popup inside the placeholder view
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender);
        if(segue.identifier == BlueMSCalibrationViewController.SHOW_CALIBRATION_SEGUE){
            mCalibDialog = segue.destination as? BlueMSSimpleDialogViewController;
            if let popupController = mCalibDialog?.popoverPresentationController{
                popupController.displayOnView(mDialogViewPlaceHolder);
            }
        }
    }
    
}
