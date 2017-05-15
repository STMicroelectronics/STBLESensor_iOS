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
import UIKit


/// list of available language
public enum BlueVoiceLangauge:String{
    
    case ENGLISH = "English"
    case ITALIAN = "Italian"
    case FRENCH = "Franch"
    case SPANISH = "Spanish"
    case GERMAN = "German"
    case PORTUGUESE = "Portugese"
    
    
    fileprivate static let allValues=[ENGLISH,ITALIAN,FRENCH,SPANISH,
                          GERMAN,PORTUGUESE];
}


/// interface used to load and store the selected voice language
protocol BlueVoiceSelectDelegate {
    
    /// get the current language
    ///
    /// - Returns: last selected language or the default one
    func getDefaultLanguage()->BlueVoiceLangauge;
    
    /// notify to the delagate that a new language is selected
    ///
    /// - Parameter language: new selected language
    func newLanguageSelected(_ language:BlueVoiceLangauge);
}


/// View controller used to select the voice to text langage
public class BlueVoiceSelectLanguageViewController: UIViewController,
    UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var mLanguagePicker: UIPickerView!
    var delegate:BlueVoiceSelectDelegate?=nil;
    
    
    override public func viewDidLoad() {
        mLanguagePicker.delegate=self;
        mLanguagePicker.dataSource=self;
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        let selectLang = delegate?.getDefaultLanguage();
        if let lang = selectLang {
            mLanguagePicker.selectRow(lang.hashValue, inComponent: 0, animated: false)
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return BlueVoiceLangauge.allValues.count;
    }
    
    public func pickerView(_ pickerView: UIPickerView,
                           titleForRow row: Int,
                           forComponent component: Int) -> String?{
        return BlueVoiceLangauge.allValues[row].rawValue;
    }

    
    /// call when the user click on the positive button
    /// close the  popup and notify to the delegate the selected language
    ///
    /// - Parameter sender: button pressed
    @IBAction func onSelectClick(_ sender: UIButton) {
        let selectedRow = mLanguagePicker.selectedRow(inComponent: 0);
        let selectLang = BlueVoiceLangauge.allValues[selectedRow];
        delegate?.newLanguageSelected(selectLang)
        self.dismiss(animated: true, completion: nil);
        
    }
    
    
    /// call when the user click on the negative button,
    /// dismiss the popup
    ///
    /// - Parameter sender: button pressed
    @IBAction func onCancelClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil);
    }
}
