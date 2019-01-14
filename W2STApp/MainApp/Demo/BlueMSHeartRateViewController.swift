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


public class BlueMSHeartRateViewController : BlueMSDemoTabViewController{
    
    private static let PULSE_ANIMATION_KEY = "BlueMSHeartRateViewController.Pulse"
    
    @IBOutlet weak var mHeartImage: UIImageView!
    @IBOutlet weak var mHeartRateLabel: UILabel!
    @IBOutlet weak var mEnergyLabel: UILabel!
    @IBOutlet weak var mRRIntervalLabel: UILabel!
    
    private var mHeartRateFeature : BlueSTSDKFeature?
    
    private var mHeartRateUnit:String?
    private var mEnergyUnit:String?
    private var mRRIntervalUnit:String?
    
    private let mPulseAnimation:CAKeyframeAnimation = {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale.xy")
        animation.values = [1.0,0.8,1.2,1.0]
        animation.keyTimes = [0.0,0.25,0.75,1.0]
        animation.duration = 0.3
        return animation
    }();
    
    private func extractUnit(fields: [BlueSTSDKFeatureField]){
        mHeartRateUnit = fields[0].unit
        mEnergyUnit = fields[1].unit
        mRRIntervalUnit = fields[2].unit
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        mHeartRateFeature = self.node.getFeatureOfType(BlueSTSDKFeatureHeartRate.self) as? BlueSTSDKFeatureHeartRate
        if let feature = mHeartRateFeature{
            extractUnit(fields: feature.getFieldsDesc())
            feature.add(self)
            node.enableNotification(feature)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let feature = mHeartRateFeature{
            feature.remove(self)
            node.disableNotification(feature)
        }
    }
    
    private static let RATE_FORMAT:String = {
        return  NSLocalizedString("%d %@",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "%d %@",
                                  comment: "%d %@");
    }();
    
    private func updateRate(_ rate:Int32){
        if (rate>0){
            mHeartRateLabel.text = String(format: BlueMSHeartRateViewController.RATE_FORMAT,
                                          rate,mHeartRateUnit ?? "")
            mHeartImage.image = #imageLiteral(resourceName: "heart")
            mHeartImage.layer.add(mPulseAnimation, forKey: BlueMSHeartRateViewController.PULSE_ANIMATION_KEY)

        }else{
            mHeartImage.image = #imageLiteral(resourceName: "heart_gray")
            mHeartRateLabel.text = nil
        }
    }
    
    private static let ENERGY_FORMAT:String = {
        return  NSLocalizedString("Energy: %d %@",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "Energy: %d %@",
                                  comment: "Energy: %d %@");
    }();
    
    private func updateEnergy(_ energy:Int32){
        if (energy>0){
            mEnergyLabel.text = String(format: BlueMSHeartRateViewController.ENERGY_FORMAT,
                                          energy,mEnergyUnit ?? "")
        }else{
            mEnergyLabel.text=nil
        }
    }
    
    private static let RR_INTERVAL_FORMAT:String = {
        return  NSLocalizedString("RR Interval: %.2f %@",
                                  tableName: nil,
                                  bundle: Bundle(for: BlueMSCloudConnectionViewController.self),
                                  value: "RR Interval: %.2f %@",
                                  comment: "RR Interval: %.2f %@");
    }();
    
    private func updateInterval(_ interval:Float){
        if(!interval.isNaN){
            mRRIntervalLabel.text = String(format: BlueMSHeartRateViewController.RR_INTERVAL_FORMAT,
                                           interval,mRRIntervalUnit ?? "")
        }else{
            mRRIntervalLabel.text = nil
        }
    }
    
    fileprivate func updateData(rate: Int32, energy:Int32, rrInterval:Float){
        updateRate(rate)
        updateEnergy(energy)
        updateInterval(rrInterval)
    }
    
}

extension BlueMSHeartRateViewController : BlueSTSDKFeatureDelegate{
        
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let rate = BlueSTSDKFeatureHeartRate.getHeartRate(sample)
        let energy = BlueSTSDKFeatureHeartRate.getEnergyExtended(sample)
        let rrInterval = BlueSTSDKFeatureHeartRate.getRRInterval(sample)
        DispatchQueue.main.async { [weak self] in
            self?.updateData(rate: rate, energy: energy, rrInterval: rrInterval)
        }
    }

}
