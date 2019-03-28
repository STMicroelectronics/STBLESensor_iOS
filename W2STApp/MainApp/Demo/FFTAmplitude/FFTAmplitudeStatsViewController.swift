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

struct FFTPoint{
    let frequency:Float
    let amplitude:Float
    
    init(frequency:Float, amplitude:Float) {
        self.frequency = frequency
        self.amplitude = amplitude
    }
    
}

struct TimeDomainStats{
    let accPreakX:Float
    let accPreakY:Float
    let accPreakZ:Float
    let rmsSpeedX:Float
    let rmsSpeedY:Float
    let rmsSpeedZ:Float
 
    init(accPreakX:Float, accPreakY:Float, accPreakZ:Float,
        rmsSpeedX:Float, rmsSpeedY:Float, rmsSpeedZ:Float){
        self.accPreakX = accPreakX
        self.accPreakY = accPreakY
        self.accPreakZ = accPreakZ
        self.rmsSpeedX = rmsSpeedX
        self.rmsSpeedY = rmsSpeedY
        self.rmsSpeedZ = rmsSpeedZ
    }
    
}


class FFTAmplitudeStatsViewController:UIViewController{
    
    private static let FREQ_MAX_FORMAT = {
        return  NSLocalizedString("%@ Max: %.4f @ %.2f Hz",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTAmplitudeStatsViewController.self),
                                  value: "%@ Max: %.4f @ %.2f Hz",
                                  comment: "%@ Max: %.4f @ %.2f Hz");
    }()
    private static let TIME_STAT_FORMAT = {
        return  NSLocalizedString("%@ Acc Peack: %.4f %@\n\tRMS Spped: %.2f %@",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTAmplitudeStatsViewController.self),
                                  value: "%@ Acc Peack: %.2f %@\n\tRMS Spped: %.2f %@",
                                  comment: "%@ Acc Peack: %.2f %@\n\tRMS Spped: %.2f %@");
    }()
    private static let TIME_STATS_UNAVAILABLE = {
        return  NSLocalizedString("Not Available",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTAmplitudeStatsViewController.self),
                                  value: "Not Available",
                                  comment: "Not Available");
    }();
    
    @IBOutlet weak var statTimeZ: UILabel!
    @IBOutlet weak var statTimeY: UILabel!
    @IBOutlet weak var statTimeX: UILabel!
    @IBOutlet weak var statFreqZ: UILabel!
    @IBOutlet weak var statFreqY: UILabel!
    @IBOutlet weak var statFreqX: UILabel!
    
    var maxPoints:[FFTPoint]?
    
    var timeDomainStats:TimeDomainStats?
    
    
    override func viewWillAppear(_ animated: Bool) {
        displayMaxPoint()
        displayTimeDomainStats()
    }
    
    private func displayTimeDomainStats(){
        guard let data = timeDomainStats else {
            [statTimeX,statTimeY,statTimeZ].forEach{
                $0?.text = FFTAmplitudeStatsViewController.TIME_STATS_UNAVAILABLE
            }
            return
        }
        
        statTimeX.text = String(format: FFTAmplitudeStatsViewController.TIME_STAT_FORMAT,
                                LINE_CONFIG[0].name,
                                data.accPreakX,
                                BlueSTSDKFeatureMotorTimeParameters.FEATURE_ACC_UNIT,
                                data.rmsSpeedX,
                                BlueSTSDKFeatureMotorTimeParameters.FEATURE_SPEED_UNIT)
        statTimeY.text = String(format: FFTAmplitudeStatsViewController.TIME_STAT_FORMAT,
                                LINE_CONFIG[1].name,
                                data.accPreakY,
                                BlueSTSDKFeatureMotorTimeParameters.FEATURE_ACC_UNIT,
                                data.rmsSpeedY,
                                BlueSTSDKFeatureMotorTimeParameters.FEATURE_SPEED_UNIT)
        statTimeZ.text = String(format: FFTAmplitudeStatsViewController.TIME_STAT_FORMAT,
                                LINE_CONFIG[2].name,
                                data.accPreakZ,
                                BlueSTSDKFeatureMotorTimeParameters.FEATURE_ACC_UNIT,
                                data.rmsSpeedZ,
                                BlueSTSDKFeatureMotorTimeParameters.FEATURE_SPEED_UNIT)
        
    }
    
    private func displayMaxPoint(){
        guard let points = maxPoints else{
            return
        }
     
        //prepare the text
        let texts = zip(LINE_CONFIG, points).map{ (arg) -> String in
            let (lineConf, values) = arg
            return String(format: FFTAmplitudeStatsViewController.FREQ_MAX_FORMAT,
                          lineConf.name,values.amplitude,values.frequency)
        }
        //hide the labels
        let labels = [self.statFreqX,self.statFreqY,self.statFreqZ]
        labels.forEach{ $0?.isHidden = true}
        //show the availble data
        zip(labels,texts).forEach{ label, value in
            label?.isHidden = false
            label?.text = value
        }
    }
    
}
