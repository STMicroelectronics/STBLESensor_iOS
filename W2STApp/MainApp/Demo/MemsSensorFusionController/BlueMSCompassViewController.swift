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
import BlueSTSDK;

/// demo that show the compass data
public class BlueMSCompassViewController: BlueMSCalibrationViewController,
    BlueSTSDKFeatureDelegate {
    
    private static let ORIENTATION = ["N","NE","E","SE","S","SW","W","NW"];
    
    private static let ORIENTATION_FORMAT:String = {
        let bundle = Bundle(for: BlueMSCompassViewController.self)
        return NSLocalizedString("Orientation: %@", tableName: nil, bundle: bundle,
                                 value: "Orientation: %@", comment: "")
    }();
    
    private static let ANGLE_FORMAT:String = {
        let bundle = Bundle(for: BlueMSCompassViewController.self)
        return NSLocalizedString("Angle: %2.2f", tableName: nil, bundle: bundle,
                                 value: "Angle: %2.2f", comment: "")
    }();
    
    @IBOutlet weak var mOrientaitonLable: UILabel!
    @IBOutlet weak var mNeedleImage: UIImageView!
    @IBOutlet weak var mAngleLabel: UILabel!
    
    private var mFeature:BlueSTSDKFeatureAutoConfigurable?;
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        mFeature = self.node.getFeatureOfType(BlueSTSDKFeatureCompass.self) as? BlueSTSDKFeatureAutoConfigurable;
        if let feature = mFeature{
            feature.add(self);
            manageCalibrationForFeature(feature);
            self.node.enableNotification(feature);
        }
    }
 
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        if let feature = mFeature{
            self.node.disableNotification(feature);
            feature.remove(self);
        }
    }
    
    private static func degreeToRad(angle:Float)->Float{
        return angle*(Float.pi/180.0)
    }

    private static func getOrientationNameForAngle(angle:Float)->String{
        let nOrientation = ORIENTATION.count;
        let section = 360.0/Double(nOrientation);
        //remove section/2 to  map the interval n*section - section/2,
        // n*section + section/2 in the index n
        let shiftAngle = Double(angle) - section/2 + 360.0;
        let index = Int(shiftAngle/section)+1;
        return ORIENTATION[index % nOrientation];
    }
    
    public func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        let angle = BlueSTSDKFeatureCompass.getAngle(sample);
        let orientation = BlueMSCompassViewController.getOrientationNameForAngle(angle: angle);
        let angleRad = BlueMSCompassViewController.degreeToRad(angle: angle);
        
        let angleStr = String(format: BlueMSCompassViewController.ANGLE_FORMAT, angle);
        let orientationStr = String(format: BlueMSCompassViewController.ORIENTATION_FORMAT,orientation);
        
        DispatchQueue.main.async {
            self.mNeedleImage.transform = CGAffineTransform(rotationAngle: CGFloat(angleRad));
            self.mOrientaitonLable.text = orientationStr;
            self.mAngleLabel.text = angleStr;
        }
    }
}
