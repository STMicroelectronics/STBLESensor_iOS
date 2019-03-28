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

@IBDesignable  class PredictiveAxisStatusView: UIView,NibLoadable{
    private static let STATUS_FORMAT = {
        return  NSLocalizedString("Status: %@",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveAxisStatusView.self),
                                  value: "Status: %@",
                                  comment: "Status: %@");
    }();
    
    
    @IBOutlet weak var statusImage:UIImageView!
    @IBOutlet weak var statusLabel:UILabel!
    @IBOutlet weak var valueXDetailsLabel: UILabel!
    
    @IBOutlet weak var valueYDetailsLabel: UILabel!
    var viewStatus:ViewStatus? {
        didSet{
            let status = viewStatus?.status ?? .UNKNOWN
            statusImage.image = status.toImage()
            statusLabel.text = statusFormater(status.toString())
            if let valueX = viewStatus?.xDetails{
                valueXDetailsLabel.text = valueX
                valueXDetailsLabel.isHidden = false
            }else{
                valueXDetailsLabel.isHidden = true
            }
            
            if let valueY = viewStatus?.yDetails{
                valueYDetailsLabel.text = valueY
                valueYDetailsLabel.isHidden = false
            }else{
                valueYDetailsLabel.isHidden = true
            }
        }
    }
    
    var statusFormater:(String)->String = {
        return String(format: PredictiveAxisStatusView.STATUS_FORMAT, $0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFromNib()
    }

    struct ViewStatus{
        let status:BlueSTSDKFeaturePredictiveStatus.Status
        let xDetails:String?
        let yDetails:String?
    }
    
}

fileprivate extension BlueSTSDKFeaturePredictiveStatus.Status{
    
    func toImage()->UIImage{
        switch(self){
            case .GOOD:
                return #imageLiteral(resourceName: "predictive_good.pdf")
            case .WARNING:
                return #imageLiteral(resourceName: "predictive_warning.pdf")
            case .BAD:
                return #imageLiteral(resourceName: "predictive_bad.pdf")
            case .UNKNOWN:
                return #imageLiteral(resourceName: "predictive_warning.pdf")
        }
    }
    
    
    private static let GOOD_STR = {
        return  NSLocalizedString("Good",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveAxisStatusView.self),
                                  value: "Good",
                                  comment: "Good");
    }();
    
    private static let BAD_STR = {
        return  NSLocalizedString("Bad",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveAxisStatusView.self),
                                  value: "Bad",
                                  comment: "Bad");
    }();
    
    private static let WARNING_STR = {
        return  NSLocalizedString("Warning",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveAxisStatusView.self),
                                  value: "Warning",
                                  comment: "Warning");
    }();
    
    private static let UNKNOWN_STR = {
        return  NSLocalizedString("Unknown",
                                  tableName: nil,
                                  bundle: Bundle(for: PredictiveAxisStatusView.self),
                                  value: "Unknown",
                                  comment: "Unknown");
    }();
    
    func toString()->String{
        switch self {
            case .GOOD:
                return BlueSTSDKFeaturePredictiveStatus.Status.GOOD_STR
            case .WARNING:
                return BlueSTSDKFeaturePredictiveStatus.Status.WARNING_STR
            case .BAD:
                return BlueSTSDKFeaturePredictiveStatus.Status.BAD_STR
            case .UNKNOWN:
                return BlueSTSDKFeaturePredictiveStatus.Status.UNKNOWN_STR
        }
    }
    
}

