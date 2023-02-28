/*
* Copyright (c) 2019  STMicroelectronics – All rights reserved
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

import UIKit
import AssetTrackingDataModel

internal class SelectThrehsolValueViewController: UIViewController {

    @IBOutlet weak var mTitleLabel: UILabel!

    @IBOutlet weak var mDescriptionLabel: UILabel!

    @IBOutlet weak var mValueDescriptionLabel: UILabel!

    @IBOutlet weak var mRangeLabel: UILabel!

    @IBOutlet weak var mUnitLabel: UILabel!
    @IBOutlet weak var mValueTextField: UITextField!
    @IBOutlet weak var mThanLabel: UILabel!
    @IBOutlet weak var mSeletion: UISegmentedControl!
    
    private let mCloseKeyboardOnReturnDelegate = CloseKeyboardOnReturn()
    
    
    private func extractComparisonType(from selection:UISegmentedControl) -> ThresholdType {
        if selection.selectedSegmentIndex == 0 {
            return .less
        }else{
            return .biggerOrEqual
        }
    }
    
    @IBAction func onSelector(_ sender: Any) {
        mComparison = extractComparisonType(from: mSeletion)
    }

    @IBAction func onValueChanged(_ sender: UITextField) {
        thresholdValue = Double(mValueTextField.text!)
        
        if let value = thresholdValue {
            if(selectedSensor.range.contains(value)) {
                 mRangeLabel.textColor = UIColor.black
                 mValueTextField.textColor = UIColor.black
                 mEnableExit = true
             } else {
                 mRangeLabel.textColor = UIColor.orange
                 mValueTextField.textColor = UIColor.orange
                 mEnableExit = false
            }
        }else{
            mRangeLabel.textColor = UIColor.red
            mValueTextField.textColor = UIColor.red
            mEnableExit = false
        }
        
    }

    var onThrehsoldCreated:((SensorThreshold?)->Void)!
    var selectedSensor: SensorType!
    private var thresholdValue: Double?
    private var mComparison: ThresholdType!

    private var mEnableExit: Bool=false

    @IBAction func onCreate(_ sender: Any) {
        if let value = thresholdValue , mEnableExit{
            let th = SensorThreshold(sensor: selectedSensor, comparison: mComparison, value: value)
            dismiss(animated: true, completion: nil)
            onThrehsoldCreated(th)
        } else {
            mRangeLabel.textColor = UIColor.red
        }
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        onThrehsoldCreated(nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        mSeletion.selectedSegmentIndex = 1
        mComparison = extractComparisonType(from: mSeletion)

        mValueTextField.delegate = mCloseKeyboardOnReturnDelegate

        mEnableExit = false

        let unitString = selectedSensor.unit

        mTitleLabel.text = "Add "+selectedSensor.description+" Threshold"
        
        if let sensor = selectedSensor,
            sensor == .WakeUp{
            
            mDescriptionLabel.text = SelectThrehsolValueViewController.TEXT_RECORD_WAKEUP
                            mValueDescriptionLabel.text = SelectThrehsolValueViewController.TEXT_RECORD_WAKEUP_NAME

            mThanLabel.isHidden = true
            mSeletion.isHidden = true

        } else {

            mDescriptionLabel.text = SelectThrehsolValueViewController.TEXT_RECORD
            mValueDescriptionLabel.text = SelectThrehsolValueViewController.TEXT_RECORD_NAME

        }

        mUnitLabel.text = unitString

        let minString = String(format: selectedSensor.dataFormat, selectedSensor.range.lowerBound)
        let maxString = String(format: selectedSensor.dataFormat, selectedSensor.range.upperBound)

        mRangeLabel.text = String(format: SelectThrehsolValueViewController.TEXT_RANGE_FORMAT, minString,maxString,unitString)
    }

}

extension SelectThrehsolValueViewController {
    private static let TEXT_RECORD_WAKEUP = {
       return  NSLocalizedString("Record a event when a shock is detected",
                                 tableName: nil,
                                 bundle: TrackerThresholdUtilBundle.bundle(),
                                 value: "Record a event when a shock is detected",
                                 comment: "Record a event when a shock is detected");
    }()

    private static let TEXT_RECORD_WAKEUP_NAME = {
       return  NSLocalizedString("Acceleration shock",
                                 tableName: nil,
                                 bundle: TrackerThresholdUtilBundle.bundle(),
                                 value: "Acceleration shock",
                                 comment: "Acceleration shock");
    }()
    private static let TEXT_RECORD = {
       return  NSLocalizedString("Record a event when threshold value is",
                                 tableName: nil,
                                 bundle: TrackerThresholdUtilBundle.bundle(),
                                 value: "Record a event when threshold value is",
                                 comment: "Record a event when threshold value is");
    }()
    private static let TEXT_RECORD_NAME = {
       return  NSLocalizedString("value",
                                 tableName: nil,
                                 bundle: TrackerThresholdUtilBundle.bundle(),
                                 value: "value",
                                 comment: "value");
    }()
    private static let TEXT_RANGE_FORMAT = {
       return  NSLocalizedString("The possible range is [ %@ : %@ ] ( %@ )",
                                 tableName: nil,
                                 bundle: TrackerThresholdUtilBundle.bundle(),
                                 value: "The possible range is [ %@ : %@ ] ( %@ )",
                                 comment: "The possible range is [ %@ : %@ ] ( %@ )");
    }()
}
