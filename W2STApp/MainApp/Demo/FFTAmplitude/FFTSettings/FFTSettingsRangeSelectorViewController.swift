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

import Foundation

class FFTSettingsRangeSelectorViewController : UIViewController{
    
    private static let RANGE_DESCRIPTION_FORMAT = {
        return  NSLocalizedString("The data must be in the range [%d, %d]",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "The data must be in the range [%d, %d]",
                                  comment: "The data must be in the range [%d, %d]");
    }();
    
    @IBOutlet weak var mTitleBar: UINavigationItem!
    @IBOutlet weak var mRangeLabel: UILabel!
    @IBOutlet weak var mErrorLabel: UILabel!
    @IBOutlet weak var mUserInput: UITextField!
    
    var dataRange:ClosedRange<Int>!
    var currentValue:Int?=nil
    var onValueChange:((Int)->Void)?=nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mUserInput.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        mRangeLabel.text = String(format:FFTSettingsRangeSelectorViewController.RANGE_DESCRIPTION_FORMAT,
            dataRange.lowerBound,dataRange.upperBound)
        let value = currentValue ?? dataRange.lowerBound
        mUserInput.text = "\(value)"
        mTitleBar.title = self.title
        
    }
    
    @IBAction func onSavePressed(_ sender: UIBarButtonItem) {
        if let value = Int(mUserInput.text ?? ""),
            dataRange.contains(value){
            onValueChange?(value)
        }
        self.removeCurrentViewController()
    }
    
    @IBAction func onCancelPressed(_ sender: UIBarButtonItem) {
        self.removeCurrentViewController()
    }
    
}

extension FFTSettingsRangeSelectorViewController : UITextFieldDelegate{
    
    private static let OUT_OF_RANGE_ERROR = {
        return  NSLocalizedString("The value is out of range",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "The value is out of range",
                                  comment: "The value is out of range");
    }();
    
    private static let NOT_A_NUMBER = {
        return  NSLocalizedString("The value is not a number",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "The value is not a number",
                                  comment: "The value is not a number");
    }();
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        let str = textField.text ?? ""
        let nextStr = str.replacingCharacters(in: Range(range, in: str)!, with: string)
        guard let value = Int(nextStr) else{
            mErrorLabel.text = FFTSettingsRangeSelectorViewController.NOT_A_NUMBER
            return true
        }
        if( dataRange.contains(value)){
            mErrorLabel.text = nil
        }else{
            mErrorLabel.text = FFTSettingsRangeSelectorViewController.OUT_OF_RANGE_ERROR
        }
        return true
    }
}
