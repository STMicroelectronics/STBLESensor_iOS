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

class FFTSettingsViewController : UIViewController, UITableViewDelegate{
    
    private static let RANGE_POP_UP_SIZE = CGSize(width: 320, height: 200)
    private static let SELECTOR_POP_UP_SIZE = CGSize(width: 320, height: 400)
    
    private static let WINDOW_TYPE_TITLE = {
        return  NSLocalizedString("FFT Window type",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "FFT Window type",
                                  comment: "FFT Window type");
    }();

    
    private static let ODR_TITLE = {
        return  NSLocalizedString("Sensor Output Data Rate (Hz)",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Sensor Output Data Rate (Hz)",
                                  comment: "Sensor Output Data Rate (Hz)");
    }();
    
    private static let SIZE_TITLE = {
        return  NSLocalizedString("FFT Size",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "FFT Size",
                                  comment: "FFT Size");
    }();
    
    private static let FULL_SCALE_TITLE = {
        return  NSLocalizedString("Sensor Full Scale (g)",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Sensor Full Scale (g)",
                                  comment: "Sensor Full Scale (g)");
    }();
    
    private static let OVERLAP_TITLE = {
        return  NSLocalizedString("Overlap (%)",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Overlap (%)",
                                  comment: "Overlap (%)");
    }();
    
    private static let SUB_RANGE_TITLE = {
        return  NSLocalizedString("Number of Sub ranges",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Number of Sub ranges",
                                  comment: "Number of Sub ranges");
    }();
    
    private static let ACQUISITION_TITLE = {
        return  NSLocalizedString("Acquisition time (ms)",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Acquisition time (ms)",
                                  comment: "Acquisition time (ms)");
    }();
    
    private static let LOADING = {
        return  NSLocalizedString("Loading...",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Loading...",
                                  comment: "Loading...");
    }();
    
    private static let ERROR_LOADING = {
        return  NSLocalizedString("Error Loading data",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Error Loading data",
                                  comment: "Error Loading data");
    }();
    
    fileprivate var windowTypeCell: UITableViewCell!
    fileprivate var odrCell: UITableViewCell!
    fileprivate var sizeCell: UITableViewCell!
    fileprivate var fullScaleCell: UITableViewCell!
    fileprivate var subRangeCell: UITableViewCell!
    fileprivate var overlapCell: UITableViewCell!
    fileprivate var acquisitionTime: UITableViewCell!
    
    @IBOutlet weak var titleBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    private var mSettings:FFTSettings?
    
    var console:BlueSTSDKDebug! {
        didSet{
            mFftConsole = FFTSettingsConsole(console: console)
        }
    }
    
    private var mFftConsole:FFTSettingsConsole!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        titleBar.topItem?.title = self.title
        titleBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(close))
    }

    @objc public func close(){
        dismiss(animated: true, completion: nil)
    }
    
    private func setAllDetailsCellTo(_ str:String){
        [windowTypeCell,odrCell,sizeCell,fullScaleCell,subRangeCell,overlapCell,acquisitionTime].forEach{
            $0.detailTextLabel?.text = str
        }
    }
    
    private func loadSettings(){
        if(mSettings == nil){
            mFftConsole.readSettings{ [weak self] settings in
                DispatchQueue.main.async {
                    if let settings = settings{
                        self?.showSettings(settings)
                    }else{
                        self?.setAllDetailsCellTo(FFTSettingsViewController.ERROR_LOADING)
                    }// if settings
                }// main async
            }//readSettings
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadSettings()
    }
    
    private func showSettings(_ settings:FFTSettings){
        mSettings = settings
        windowTypeCell.detailTextLabel?.text = settings.winType.toString()
        odrCell.detailTextLabel?.text = String(format:"%d",settings.odr)
        sizeCell.detailTextLabel?.text = String(format:"%d",settings.size)
        fullScaleCell.detailTextLabel?.text = String(format:"%d",settings.fullScale)
        subRangeCell.detailTextLabel?.text = String(format:"%d",settings.subRange)
        overlapCell.detailTextLabel?.text = String(format:"%d",settings.overlap)
        acquisitionTime.detailTextLabel?.text = String(format:"%d",settings.acqusitionTime_s)
    }
    
    private func setWindowType(){
        guard mSettings != nil else {
            return
        }
        let values = FFTSettings.WindowType.allCases.map{$0.toString()}
        let current = FFTSettings.WindowType.allCases.firstIndex(of: mSettings!.winType) ?? 0
        showDataSelector(title:FFTSettingsViewController.WINDOW_TYPE_TITLE, values: values, index: Int(current)){
            [weak self] selectedIndex in
            let selectedValue = FFTSettings.WindowType.allCases[selectedIndex]
            self?.mFftConsole.setWindowType(selectedValue)
            if let newSettings = self?.mSettings?.copyWith( winType:selectedValue){
                self?.showSettings(newSettings)
            }
        }
    }
    
    
    private func showDataSelector(title:String, values:[String], index:Int, onSelected:@escaping (Int)->Void ){
        let bundle = Bundle(for: FFTSettingsSelectorViewController.self)
        if let selector = UIStoryboard(name: "FFTAmplitude", bundle: bundle)
            .instantiateViewController(withIdentifier: "FFTSettingsSelectorViewController") as? FFTSettingsSelectorViewController {
            selector.title = title
            selector.values = values
            selector.selectedIndex = index
            selector.onValueSelected = { index in
                onSelected(index)
                selector.removeCurrentViewController()
            }
            showPopUp(vc: selector, size: FFTSettingsViewController.SELECTOR_POP_UP_SIZE)
        }
    }
    
    private func showDataSelector(title:String, values:ClosedRange<Int>, currentValue:Int?, onSelected:@escaping (Int)->Void ){
        let bundle = Bundle(for: FFTSettingsSelectorViewController.self)
        if let selector = UIStoryboard(name: "FFTAmplitude", bundle: bundle)
            .instantiateViewController(withIdentifier: "FFTSettingsRangeSelectorViewController") as? FFTSettingsRangeSelectorViewController {
            selector.title = title
            selector.dataRange = values
            selector.currentValue = currentValue
            selector.onValueChange = onSelected
            showPopUp(vc: selector, size: FFTSettingsViewController.RANGE_POP_UP_SIZE)
        }
    }
    
    private func showPopUp(vc: UIViewController, size:CGSize){
        vc.modalPresentationStyle = .popover
        vc.popoverPresentationController?.sourceView=self.view
        vc.popoverPresentationController?.permittedArrowDirections=[]
        vc.popoverPresentationController?.displayWithSize(CGSize(width: 320, height: 200))
        showDetailViewController(vc, sender: nil)
    }
    
    private func setOdrCell(){
        guard mSettings != nil else {
            return
        }
        let values = FFTSettingsConsole.ODR_VALUES.map{"\($0)"}
        let current = FFTSettingsConsole.ODR_VALUES.firstIndex(of: mSettings!.odr) ?? 0
        showDataSelector(title:FFTSettingsViewController.ODR_TITLE, values: values, index: current){ [weak self] selectedIndex in
            let selectedValue = FFTSettingsConsole.ODR_VALUES[selectedIndex]
            self?.mFftConsole.setOdr(selectedValue)
            if let newSettings = self?.mSettings?.copyWith(odr: selectedValue){
                self?.showSettings(newSettings)
            }
        }
    }
    
    private func setSizeCell(){
        guard mSettings != nil else{
            return
        }
        let values = FFTSettingsConsole.SIZE_VALUES.map{"\($0)"}
        let current = FFTSettingsConsole.SIZE_VALUES.firstIndex(of: mSettings!.size) ?? 0
        showDataSelector(title:FFTSettingsViewController.SIZE_TITLE,values: values, index: current){ [weak self] selectedIndex in
            let selectedValue = FFTSettingsConsole.SIZE_VALUES[selectedIndex]
            self?.mFftConsole.setFFTSize(selectedValue)
            if let newSettings = self?.mSettings?.copyWith(size: selectedValue){
                self?.showSettings(newSettings)
            }
        }
    }
    
    private func setFullScaleCell(){
        guard mSettings != nil else{
            return
        }
        let values = FFTSettingsConsole.FULL_SCALE_VALUES.map{"\($0)"}
        let current = FFTSettingsConsole.FULL_SCALE_VALUES.firstIndex(of: mSettings!.fullScale) ?? 0
        showDataSelector(title:FFTSettingsViewController.FULL_SCALE_TITLE, values: values, index: current){ [weak self] selectedIndex in
            let selectedValue = FFTSettingsConsole.FULL_SCALE_VALUES[selectedIndex]
            self?.mFftConsole.setSensorFullScale(selectedValue)
            if let newSettings = self?.mSettings?.copyWith(fullScale: selectedValue){
                self?.showSettings(newSettings)
            }
        }
    }

    private func setSubRangeCell(){
        guard mSettings != nil else{
            return
        }
        let values = FFTSettingsConsole.SUB_RANGE.map{"\($0)"}
        let current = FFTSettingsConsole.SUB_RANGE.firstIndex(of: mSettings!.fullScale) ?? 0
        showDataSelector(title:FFTSettingsViewController.SUB_RANGE_TITLE, values: values, index: current){ [weak self] selectedIndex in
            let selectedValue = FFTSettingsConsole.SUB_RANGE[selectedIndex]
            self?.mFftConsole.setSubRange(selectedValue)
            if let newSettings = self?.mSettings?.copyWith(subRange: selectedValue){
                self?.showSettings(newSettings)
            }
        }
    }
    
    private func setOverlapCell(){
        guard mSettings != nil else{
            return
        }
        let values = FFTSettingsConsole.OVERLAP_RANGE
        let current = Int(mSettings!.overlap)
        showDataSelector(title:FFTSettingsViewController.OVERLAP_TITLE,values: values, currentValue: current){
            [weak self] selectedValue in
            self?.mFftConsole.setOverlap(UInt8(selectedValue))
            if let newSettings = self?.mSettings?.copyWith(overlap: UInt8(selectedValue)){
                self?.showSettings(newSettings)
            }
        }
    }
    
    private func setAcqusitionTimeCell(){
        guard mSettings != nil else{
            return
        }
        let values = FFTSettingsConsole.ACQUISITION_TIME_RANGE
        let current = Int(mSettings!.acqusitionTime_s)
        showDataSelector(title:FFTSettingsViewController.ACQUISITION_TITLE, values: values, currentValue: current){
            [weak self] selectedValue in
            self?.mFftConsole.setAcquisitionTimeSec(UInt32(selectedValue))
            if let newSettings = self?.mSettings?.copyWith(acqusitionTime_s: UInt32(selectedValue)){
                self?.showSettings(newSettings)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        guard let cell =  tableView.cellForRow(at: indexPath) else {
            return
        }
        switch cell {
            case windowTypeCell:
                return setWindowType()
            case odrCell:
                return setOdrCell()
            case sizeCell:
                return setSizeCell()
            case fullScaleCell:
                return setFullScaleCell()
            case subRangeCell:
                return setSubRangeCell()
            case overlapCell:
                return setOverlapCell()
            case acquisitionTime:
                return setAcqusitionTimeCell()
            default:
                return
        }
    }

}


extension FFTSettingsViewController : UITableViewDataSource{
    
    private static let CELL_ID = "FttSettingsCellID"
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:FFTSettingsViewController.CELL_ID)
        
        switch indexPath.row {
            case 0:
                windowTypeCell = cell
                cell?.textLabel?.text = FFTSettingsViewController.WINDOW_TYPE_TITLE
                break
            case 1:
                odrCell = cell
                cell?.textLabel?.text = FFTSettingsViewController.ODR_TITLE
                break
            case 2:
                sizeCell = cell
                cell?.textLabel?.text = FFTSettingsViewController.SIZE_TITLE
                break
            case 3:
                fullScaleCell = cell
                cell?.textLabel?.text = FFTSettingsViewController.FULL_SCALE_TITLE
                break
            case 4:
                subRangeCell = cell
                cell?.textLabel?.text = FFTSettingsViewController.SUB_RANGE_TITLE
                break
            case 5:
                overlapCell = cell
                cell?.textLabel?.text = FFTSettingsViewController.OVERLAP_TITLE
                break
            case 6:
                acquisitionTime = cell
                cell?.textLabel?.text = FFTSettingsViewController.ACQUISITION_TITLE
            default:
                break
        }
        cell?.detailTextLabel?.text = FFTSettingsViewController.LOADING
        return cell!
    }
    
    
}


fileprivate extension FFTSettings.WindowType{
    
    private static let RECTANGULAR_STR = {
        return  NSLocalizedString("Rectangular",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Rectangular",
                                  comment: "Rectangular");
    }();
    
    private static let HANNING_STR = {
        return  NSLocalizedString("Hanning",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Hanning",
                                  comment: "Hanning");
    }();
    
    private static let HAMMING_STR = {
        return  NSLocalizedString("Hamming",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Hamming",
                                  comment: "Hamming");
    }();
    
    private static let FLAT_TOP_STR = {
        return  NSLocalizedString("Flat Top",
                                  tableName: nil,
                                  bundle: Bundle(for: FFTSettingsViewController.self),
                                  value: "Flat Top",
                                  comment: "Flat Top");
    }();
    
    func toString() -> String{
        switch self {
        case .RECTANGULAR:
            return FFTSettings.WindowType.RECTANGULAR_STR
        case .HANNING:
            return FFTSettings.WindowType.HANNING_STR
        case .HAMMING:
            return FFTSettings.WindowType.HAMMING_STR
        case .FLAT_TOP:
            return FFTSettings.WindowType.FLAT_TOP_STR
        }
        
        
    }
    
}
