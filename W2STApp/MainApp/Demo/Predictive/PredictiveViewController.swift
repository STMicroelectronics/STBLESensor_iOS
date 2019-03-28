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

class PredictiveViewController : BlueMSDemoTabViewController{
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var speedStatusView: PredictiveStatusView!
    @IBOutlet weak var accelerationStatusView: PredictiveStatusView!
    @IBOutlet weak var frequencyDomainStatusView: PredictiveStatusView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSpeedStatus(speedStatusView)
        initAccelerationStatus(accelerationStatusView)
        initFrequencyDomainStatus(frequencyDomainStatusView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enableNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disableNotification()
    }
        
}

fileprivate extension PredictiveViewController{
    private static let SPEED_STATE_TITLE = {
        return  NSLocalizedString("RMS Speed Status",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveViewController.self),
                                  value: "Speed Status",
                                  comment: "Speed Status");
    }();
    
    private static let SPEED_VALUE_FORMAT = {
        return  NSLocalizedString("RMS Speed: %.2f mm/s",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveViewController.self),
                                  value: "RMS Speed: %.2f mm/s",
                                  comment: "RMS Speed: %.2f mm/s");
    }();
    
    fileprivate func initSpeedStatus(_ view:PredictiveStatusView){
        view.title = PredictiveViewController.SPEED_STATE_TITLE
        view.valueYFormater = {
            $0.formatOrNil(format: PredictiveViewController.SPEED_VALUE_FORMAT)
        }
    }
    
    fileprivate func updateSpeedStatus(sample:BlueSTSDKFeatureSample, view:PredictiveStatusView){
        view.setXStatus(status: BlueSTSDKFeaturePredictiveSpeedStatus.getStatusX(sample),
                        y:BlueSTSDKFeaturePredictiveSpeedStatus.getSpeedX(sample))
        view.setYStatus(status: BlueSTSDKFeaturePredictiveSpeedStatus.getStatusY(sample),
                        y:BlueSTSDKFeaturePredictiveSpeedStatus.getSpeedY(sample))
        view.setZStatus(status: BlueSTSDKFeaturePredictiveSpeedStatus.getStatusZ(sample),
                        y:BlueSTSDKFeaturePredictiveSpeedStatus.getSpeedZ(sample))
    }
}

fileprivate extension PredictiveViewController{
    private static let ACCELERATION_STATE_TITLE = {
        return  NSLocalizedString("Acceleration Peak Status",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveViewController.self),
                                  value: "Acceleration Peak Status",
                                  comment: "Acceleration Peak Status");
    }();
    
    private static let ACCELERATION_VALUE_FORMAT = {
        return  NSLocalizedString("Acc Peak: %.2f m/s^2",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveViewController.self),
                                  value: "Acc Peak: %.2f m/s^2",
                                  comment: "Acc Peak: %.2f m/s^2");
    }();
    
    fileprivate func initAccelerationStatus(_ view:PredictiveStatusView){
        view.title = PredictiveViewController.ACCELERATION_STATE_TITLE
        view.valueYFormater = {
            $0.formatOrNil(format: PredictiveViewController.ACCELERATION_VALUE_FORMAT)
        }
    }
    
    fileprivate func updateAccelerationStatus(sample:BlueSTSDKFeatureSample, view:PredictiveStatusView){
        view.setXStatus(status: BlueSTSDKFeaturePredictiveAccelerationStatus.getStatusX(sample),
                        y:BlueSTSDKFeaturePredictiveAccelerationStatus.getAccX(sample))
        view.setYStatus(status: BlueSTSDKFeaturePredictiveAccelerationStatus.getStatusY(sample),
                        y:BlueSTSDKFeaturePredictiveAccelerationStatus.getAccY(sample))
        view.setZStatus(status: BlueSTSDKFeaturePredictiveAccelerationStatus.getStatusZ(sample),
                        y:BlueSTSDKFeaturePredictiveAccelerationStatus.getAccZ(sample))
    }
    
}

fileprivate extension PredictiveViewController{
    private static let FREQUENCY_DOMAIN_STATE_TITLE = {
        return  NSLocalizedString("Frequency Domain Status",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveViewController.self),
                                  value: "Frequency Domain Status",
                                  comment: "Frequency Domain Status");
    }();
    
    private static let FREQUENCY_DOMAIN_X_VALUE_FORMAT = {
        return  NSLocalizedString("Frequency: %.2f Hz",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveViewController.self),
                                  value: "Frequency: %.2f Hz",
                                  comment: "Frequency: %.2f Hz");
    }();
    
    private static let FREQUENCY_DOMAIN_Y_VALUE_FORMAT = {
        return  NSLocalizedString("Max Amplitude: %.2f m/s^2",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveViewController.self),
                                  value: "Max Amplitude: %.2f m/s^2",
                                  comment: "Max Amplitude: %.2f m/s^2");
    }();
    
    fileprivate func initFrequencyDomainStatus(_ view:PredictiveStatusView){
        view.title = PredictiveViewController.FREQUENCY_DOMAIN_STATE_TITLE
        view.valueXFormater = {
            $0.formatOrNil(format: PredictiveViewController.FREQUENCY_DOMAIN_X_VALUE_FORMAT)
        }
        view.valueYFormater = {
            $0.formatOrNil(format: PredictiveViewController.FREQUENCY_DOMAIN_Y_VALUE_FORMAT)
        }
    }
    
    fileprivate func updateFrequencyDomainStatus(sample:BlueSTSDKFeatureSample, view:PredictiveStatusView){
        view.setXStatus(status: BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getStatusX(sample),
                        x:BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getWorstXFrequency(sample),
                        y:BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getWorstXValue(sample))
        view.setYStatus(status: BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getStatusY(sample),
                        x:BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getWorstYFrequency(sample),
                        y:BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getWorstYValue(sample))
        view.setZStatus(status: BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getStatusZ(sample),
                        x:BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getWorstXFrequency(sample),
                        y:BlueSTSDKFeaturePredictiveFrequencyDomainStatus.getWorstXValue(sample))
    }
    
}

extension PredictiveViewController: BlueSTSDKFeatureDelegate{
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        switch feature {
            case is BlueSTSDKFeaturePredictiveFrequencyDomainStatus:
                DispatchQueue.main.async {  [weak self] in
                    self?.updateFrequencyDomainStatus(sample: sample, view: self!.frequencyDomainStatusView)
                }
            case is BlueSTSDKFeaturePredictiveAccelerationStatus:
                DispatchQueue.main.async {   [weak self] in
                    self?.updateAccelerationStatus(sample: sample, view: self!.accelerationStatusView!)
                }
            case is BlueSTSDKFeaturePredictiveSpeedStatus:
                DispatchQueue.main.async {  [weak self] in
                    self?.updateSpeedStatus(sample: sample, view: self!.speedStatusView!)
                }
            default:
                return
        }
    }
    
    fileprivate func enableNotification(){
        enableSpeedNotification()
        enableAccelerationNotification()
        enableFrequencyDomainNotification()
    }
    
    fileprivate func disableNotification(){
        disableSpeedNotification()
        disableAccelerationNotification()
        disableFrequencyDomainNotification()
    }
    
    private func enableNotification(type: AnyClass) -> Bool{
        if let feature = node.getFeatureOfType(type){
            feature.add(self)
            feature.enableNotification()
            return true
        }else {
            return false
        }
    }
    
    private func disableNotification(type: AnyClass){
        if let feature = node.getFeatureOfType(type){
            feature.remove(self)
            feature.disableNotification()
        }
    }
    
    private func enableFrequencyDomainNotification(){
        let isVisible = enableNotification(type: BlueSTSDKFeaturePredictiveFrequencyDomainStatus.self)
        frequencyDomainStatusView.isHidden = !isVisible
    }
    
    private func disableFrequencyDomainNotification(){
        disableNotification(type: BlueSTSDKFeaturePredictiveFrequencyDomainStatus.self)
    }
    
    private func enableAccelerationNotification(){
        let isVisible = enableNotification(type: BlueSTSDKFeaturePredictiveAccelerationStatus.self)
        accelerationStatusView.isHidden = !isVisible
    }
    
    private func disableAccelerationNotification(){
        disableNotification(type: BlueSTSDKFeaturePredictiveAccelerationStatus.self)
    }
    
    private func enableSpeedNotification(){
        let isVisible = enableNotification(type: BlueSTSDKFeaturePredictiveSpeedStatus.self)
        speedStatusView.isHidden = !isVisible
    }
    
    private func disableSpeedNotification(){
        disableNotification(type: BlueSTSDKFeaturePredictiveSpeedStatus.self)
    }
}

fileprivate extension Optional where Wrapped == Float {
    
    fileprivate func formatOrNil(format:String)->String?{
        if let value = self {
            return String(format: format, value)
        }
        return nil
    }
    
}
