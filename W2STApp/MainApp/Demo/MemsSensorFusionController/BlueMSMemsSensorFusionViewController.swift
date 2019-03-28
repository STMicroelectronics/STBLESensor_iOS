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

import Foundation;
import BlueSTSDK;
import SceneKit;
import GLKit;
import AudioToolbox

public class BlueMSMemsSensorFusionViewController: BlueMSCalibrationViewController,
    BlueSTSDKFeatureDelegate,
    BlueMSSimpleDialogViewControllerDelegate {

    //consider the poximity as a float value, since we use it for scale the cube
    private typealias PoroximityType = Float;

    private static let SCENE_MODEL_FILE = "art.scnassets/cubeModel.dae";
    private static let SCENE_MODEL_NAME = "Cube";
    private static let CUBE_DEFAULT_SCALE = Float(1.5);

    private static let FREE_FALL_MESSAGE:String = {
        let bundle = Bundle(for: BlueMSMemsSensorFusionViewController.self)
        return NSLocalizedString("Free fall detected!", tableName: nil, bundle: bundle,
                                 value: "Free fall detected!", comment: "")
    }();

    private static let NUCLEO_RESET_POSITION_MESSAGE:String = {
        let bundle = Bundle(for: BlueMSMemsSensorFusionViewController.self)
        return NSLocalizedString("Keep the board as shown in the image", tableName: nil, bundle: bundle,
                                 value: "Keep the board as shown in the image", comment: "")
    }();

    private static let GENERIC_RESET_POSITION_MESSAGE:String = {
        let bundle = Bundle(for: BlueMSMemsSensorFusionViewController.self)
        return NSLocalizedString("Keep the board horizontaly", tableName: nil, bundle: bundle,
                                 value: "Keep the board horizontaly", comment: "")
    }();

    private static let LICENSE_NOT_VALID_MESSAGE:String = {
        let bundle = Bundle(for: BlueMSMemsSensorFusionViewController.self)
        return NSLocalizedString("Check the license", tableName: nil, bundle: bundle,
                                 value: "Check the license", comment: "")
    }();

    private static let DISTANCE_OUT_OF_RANGE:String = {
        let bundle = Bundle(for: BlueMSMemsSensorFusionViewController.self)
        return NSLocalizedString("Distance: Out of range", tableName: nil, bundle: bundle,
                                 value: "Distance: Out of range", comment: "")
    }();
    
    private static let DISTANCE_FORMAT:String = {
        let bundle = Bundle(for: BlueMSMemsSensorFusionViewController.self)
        return NSLocalizedString("Distance: %.0f mm", tableName: nil, bundle: bundle,
                                 value: "Distance: %.0f mm", comment: "")
    }();
    
    private static let FREE_FALL_DIALOG_DURATION_S = TimeInterval(2.0);
    private static let MAX_PROXIMITY_VALUE = PoroximityType(255);

    private static let RESET_POSITION_SEGUE = "ResetPositionDialogID";

    @IBOutlet weak var mProximityText: UILabel!
    @IBOutlet weak var m3DCubeView: SCNView!
    @IBOutlet weak var mProximityButton: UIButton!

    private var mResetQuat = GLKQuaternionIdentity;
    private var m3DScene:SCNScene!;
    private var m3DCube:SCNNode!;

    private var mSensorFusion:BlueSTSDKFeatureAutoConfigurable?;
    private var mFreeFall: BlueSTSDKFeatureAccelerometerEvent?;
    private var mProximity : BlueSTSDKFeature?;

    private var mResetPositionDialog: BlueMSSimpleDialogViewController?;

    private func init3DCubeScene(){
        m3DScene = SCNScene(named: BlueMSMemsSensorFusionViewController.SCENE_MODEL_FILE);
        m3DCube = m3DScene.rootNode.childNode(withName: BlueMSMemsSensorFusionViewController.SCENE_MODEL_NAME, recursively: true);
        setCubeScaleFactor(BlueMSMemsSensorFusionViewController.CUBE_DEFAULT_SCALE)
        m3DCubeView.prepare(m3DCube, shouldAbortBlock: nil);
        m3DCubeView.scene = m3DScene;
    }

    public override func viewDidLoad() {
        init3DCubeScene();
    }

    private func enableMemsSensorFusion(){
        mSensorFusion = self.node.getFeatureOfType(BlueSTSDKFeatureMemsSensorFusionCompact.self) as? BlueSTSDKFeatureAutoConfigurable;

        //if the compact are not preset try use the normal one
        if (mSensorFusion == nil){
            mSensorFusion = self.node.getFeatureOfType(BlueSTSDKFeatureMemsSensorFusion.self) as? BlueSTSDKFeatureAutoConfigurable;
        }

        if let feature = mSensorFusion{
            feature.add(self);
            manageCalibrationForFeature(feature);
            self.node.enableNotification(feature);
        }
    }

    private func disableMemsSensorFusion(){
        if let feature = mSensorFusion{
            self.node.disableNotification(feature);
            manageCalibrationForFeature(nil);
            feature.remove(self);
        }
    }

    private func enableFreeFall(){
        mFreeFall = self.node.getFeatureOfType(BlueSTSDKFeatureAccelerometerEvent.self) as? BlueSTSDKFeatureAccelerometerEvent;
        if let feature = mFreeFall{
            self.node.enableNotification(feature);
            feature.enable(feature.DEFAULT_ENABLED_EVENT, enable: false)
            feature.enable(.eventTypeFreeFall, enable: true);
            feature.add(self);
        }
    }

    private func disableFreeFall(){
        if let feature = mFreeFall{
            self.node.disableNotification(feature);
            feature.remove(self);
        }
    }

    private func enableProximity(){
        mProximity = self.node.getFeatureOfType(BlueSTSDKFeatureProximity.self);
        if let feature = mProximity{
            feature.add(self)
            mProximityButton.isSelected=true
            mProximityButton.isEnabled=true
            mProximityButton.alpha=1
            mProximityText.isHidden=false
            self.node.enableNotification(feature)
        }else{
            mProximityButton.isSelected=false
            mProximityButton.isEnabled=false
            mProximityButton.alpha=0
            mProximityText.isHidden=true
        }
    }

    private func disableProximity(){
        if let feature = mProximity{
            self.node.disableNotification(feature);
            feature.remove(self);
        }
        mProximityButton.isSelected=false;
        mProximityText.isHidden=true
    }


    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        enableFreeFall();
        enableProximity();
        enableMemsSensorFusion();
        
        if(self.node.type == .STEVAL_WESU1){
            checkLicense(fromRegister: .REGISTER_NAME_MOTION_FX_CALIBRATION_LIC_STATUS,
                         errorString: BlueMSMemsSensorFusionViewController.LICENSE_NOT_VALID_MESSAGE);
        }
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        disableFreeFall();
        disableProximity();
        disableMemsSensorFusion();
    }

    @IBAction func onResetPositionClick(_ sender: UIButton) {
        performSegue(withIdentifier: BlueMSMemsSensorFusionViewController.RESET_POSITION_SEGUE, sender: self);
    }

    @IBAction func onProximityButtonClicked(_ sender: UIButton) {

        guard mProximity != nil else{
            return;
        }

        if(self.node.isEnableNotification(mProximity!)){
            disableProximity();
            setCubeScaleFactor(BlueMSMemsSensorFusionViewController.CUBE_DEFAULT_SCALE);
            sender.isSelected=false;
        }else{
            enableProximity();
            sender.isSelected=true;
        }
    }

    override func onCalibStart(){
        disableFreeFall();
        disableProximity();
        super.onCalibStart();
    }

    override func onCalibComplete(){
        super.onCalibComplete()
        enableFreeFall();
        enableProximity();
    }

    /// rotete the cube using the data from the sample
    private func updateCubeRotation(sample:BlueSTSDKFeatureSample){
        var temp = BlueMSMemsSensorFusionViewController.extractQuaternion(sample: sample);

        temp = GLKQuaternionMultiply(mResetQuat, temp);

        let rot = SCNQuaternion(x: temp.x, y: temp.y, z: temp.z, w: temp.w);
        DispatchQueue.main.async {
            self.m3DCube?.orientation = rot;
        }

    }

    /// show a message if a free fall event appear
    private func updateFreeFall(sample: BlueSTSDKFeatureSample){
        if( BlueSTSDKFeatureAccelerometerEvent.getAccelerationEvent(sample) == .freeFall){
            DispatchQueue.main.async {
                let message = MBProgressHUD.showAdded(to: self.view, animated: true);
                message.mode = .text;
                message.removeFromSuperViewOnHide=true;
                message.label.text = BlueMSMemsSensorFusionViewController.FREE_FALL_MESSAGE;
                message.hide(animated: true, afterDelay: BlueMSMemsSensorFusionViewController.FREE_FALL_DIALOG_DURATION_S);
                AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
            }//async
        }//iof envet
    }

    //update the cube scale factor
    private func updateProximty(sample:BlueSTSDKFeatureSample){

        let distance = PoroximityType(BlueSTSDKFeatureProximity.getDistance(sample));
        if (distance != PoroximityType(BlueSTSDKFeatureProximity.outOfRangeValue())){
            let scaleDistance = PoroximityType.minimum(distance, BlueMSMemsSensorFusionViewController.MAX_PROXIMITY_VALUE);
            let scale = BlueMSMemsSensorFusionViewController.CUBE_DEFAULT_SCALE*(scaleDistance/BlueMSMemsSensorFusionViewController.MAX_PROXIMITY_VALUE);
            setCubeScaleFactor(scale);
            DispatchQueue.main.async {
                self.mProximityText.text = String(format:BlueMSMemsSensorFusionViewController.DISTANCE_FORMAT,distance);
            }
        }else{
            setCubeScaleFactor(BlueMSMemsSensorFusionViewController.CUBE_DEFAULT_SCALE)
            DispatchQueue.main.async {
                self.mProximityText.text = BlueMSMemsSensorFusionViewController.DISTANCE_OUT_OF_RANGE
            }
        }
    }

    //change the cube scale factor
    private func setCubeScaleFactor(_ scale:Float){
        m3DCube.scale = SCNVector3Make(scale,scale,scale);
    }

    /// dispatch the node update event
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        if(feature == mSensorFusion){
            updateCubeRotation(sample: sample);
            return;
        }

        if(feature == mFreeFall){
            updateFreeFall(sample: sample);
            return;
        }

        if(feature == mProximity){
            updateProximty(sample:sample);
            return;
        }
    }


    //set the current cube position as the default one
    private func resetCubePosition(){
        let sample = mSensorFusion?.lastSample;
        if let currentPostion = sample{
            mResetQuat = GLKQuaternionInvert(
                BlueMSMemsSensorFusionViewController.extractQuaternion(sample: currentPostion)
            );
        }
    }


    /// create a quaternion from the node sensor fusion datas
    private static func extractQuaternion( sample: BlueSTSDKFeatureSample) -> GLKQuaternion{
        var temp = GLKQuaternion();
        temp.z =  -BlueSTSDKFeatureMemsSensorFusion.getQi(sample);
        temp.y =   BlueSTSDKFeatureMemsSensorFusion.getQj(sample);
        temp.x =   BlueSTSDKFeatureMemsSensorFusion.getQk(sample);
        temp.w =   BlueSTSDKFeatureMemsSensorFusion.getQs(sample);
        return temp;
    }


    //if the reset dialog is shown set the delegate for it
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        guard segue.identifier == BlueMSMemsSensorFusionViewController.RESET_POSITION_SEGUE else{
            return;
        }
        
        let destination = segue.destination as? BlueMSSimpleDialogViewController;
        if let controller = destination{
            controller.popoverPresentationController?.displayOnView(mDialogViewPlaceHolder);
            mResetPositionDialog = controller;
            mResetPositionDialog?.delegate=self;
        }

    }

    /// get the node image to display in the dialog
    public func getDialogImage()->UIImage?{
        return self.node.getImage();
    }

    /// get the text to show in the dialog
    public func getDialogText()->String?{
        switch node.type {
            case .nucleo,.STEVAL_WESU1,.blue_Coin,.sensor_Tile:
                return BlueMSMemsSensorFusionViewController.NUCLEO_RESET_POSITION_MESSAGE;
            default:
                return BlueMSMemsSensorFusionViewController.GENERIC_RESET_POSITION_MESSAGE;
        }
    }

    /// when the dialog button is pressed dismiss it and reset the cube position
    public func onButtonPressed( dialog: BlueMSSimpleDialogViewController){
        resetCubePosition();
        mResetPositionDialog = nil;
    }
    
}
