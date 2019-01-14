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

class AIDataFrequencyParametersViewCell : UITableViewCell{
    
    private static let ENVIRONMENTAL_FREQ_VALUE_FORMAT = {
        return  NSLocalizedString("Eviromental sensors sampling frequency: %.2f Hz",
                                  tableName: nil,
                                  bundle: Bundle(for: AIDataFrequencyParametersViewCell.self),
                                  value: "Eviromental sensors sampling frequency: %.2f Hz",
                                  comment: "Eviromental sensors sampling frequency: %.2f Hz");
    }();
    
    private static let INERTIAL_FREQ_VALUE_FORMAT = {
        return  NSLocalizedString("Inertial sensors sampling frequency: %.0f Hz",
                                  tableName: nil,
                                  bundle: Bundle(for: AIDataFrequencyParametersViewCell.self),
                                  value: "Inertial sensors sampling frequency: %.0f Hz",
                                  comment: "Inertial sensors sampling frequency: %.0f Hz");
    }();
    
    private static let AUDIO_VOLUME_VALUE_FORMAT = {
        return  NSLocalizedString("Recorded audio volume: %.1f x",
                                  tableName: nil,
                                  bundle: Bundle(for: AIDataFrequencyParametersViewCell.self),
                                  value: "Recorded audio volume: %.1f x",
                                  comment: "Recorded audio volume: %.1f x");
    }();
    
    public var parameterViewModel: AIDataLogParametersViewModel!{
        didSet{
            setEnviromentalFreqLabel(parameterViewModel.environmentalFrequencyHz)
            setInertialFreqLabel(parameterViewModel.inertialFrequencyHz)
            setAudioVolumeLablel(parameterViewModel.audioVolume)
        }
    }
    
    @IBOutlet weak var audioVolumeValue: UILabel!
    @IBOutlet weak var inertialFrequencyValue: UILabel!
    @IBOutlet weak var enviromentalFrequencyValue: UILabel!
    
    var displayParametersSelection: ((AIDataLogParameterSelectorData)->())? = nil
    
    @IBAction func onEnviromentalFrequencyButtonPressed(_ sender: UIButton) {
        let data = AIDataLogParameterSelectorData(values: AIDataLogParametersViewModel.ENVIROMENTAL_FREQUENCY_CONF.values,
                                                  defaultIndex: AIDataLogParametersViewModel.ENVIROMENTAL_FREQUENCY_CONF.defaultIndex,
                                                  dataFormat: "%.1f Hz",
                                                  onSelected: {[weak self] newValue in
                                                    self?.parameterViewModel.environmentalFrequencyHz = newValue
                                                    self?.setEnviromentalFreqLabel(newValue) })
        displayParametersSelection?(data)
    }
    @IBAction func onInertialFrequencyButtonPressed(_ sender: UIButton) {
        let data = AIDataLogParameterSelectorData(values: AIDataLogParametersViewModel.INERTIAL_FREQUENCY_CONF.values,
                                                  defaultIndex: AIDataLogParametersViewModel.INERTIAL_FREQUENCY_CONF.defaultIndex,
                                                  dataFormat: "%.0f Hz",
                                                  onSelected: {[weak self] newValue in
                                                    self?.parameterViewModel.inertialFrequencyHz = newValue
                                                    self?.setInertialFreqLabel(newValue) })
        displayParametersSelection?(data)
    }
    
    @IBAction func onVolumeAudioButtonPressed(_ sender: UIButton) {
        let data = AIDataLogParameterSelectorData(values: AIDataLogParametersViewModel.AUDIO_VOLUME_CONF.values,
                                                  defaultIndex: AIDataLogParametersViewModel.AUDIO_VOLUME_CONF.defaultIndex,
                                                  dataFormat: "%.1f x",
                                                  onSelected: {[weak self] newValue in
                                                    self?.parameterViewModel.audioVolume = newValue
                                                    self?.setAudioVolumeLablel(newValue) })
        displayParametersSelection?(data)
    }
    
    private func setEnviromentalFreqLabel(_ freq:Float){
        enviromentalFrequencyValue.text = String.init(format: AIDataFrequencyParametersViewCell.ENVIRONMENTAL_FREQ_VALUE_FORMAT, freq)
    }
    
    private func setInertialFreqLabel(_ freq:Float){
        inertialFrequencyValue.text = String.init(format: AIDataFrequencyParametersViewCell.INERTIAL_FREQ_VALUE_FORMAT, freq)
    }
    
    private func setAudioVolumeLablel(_ value:Float){
        audioVolumeValue.text = String.init(format: AIDataFrequencyParametersViewCell.AUDIO_VOLUME_VALUE_FORMAT, value)
    }
    
}

fileprivate extension AIDataParameterConfiguration {
    var defaultIndex:Int {
        return values.firstIndex(of: defaultValue) ?? values.count-1
    }
}
