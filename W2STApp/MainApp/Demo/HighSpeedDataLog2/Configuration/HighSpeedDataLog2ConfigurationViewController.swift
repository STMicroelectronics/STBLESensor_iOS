//
//  HighSpeedDataLog2ConfigurationViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import BlueSTSDK
import BlueSTSDK_Gui

class HighSpeedDataLog2ConfigurationViewController: BlueMSDemoTabViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var mPnPL: BlueSTSDKFeaturePnPL?
    private var featureWasEnabled = false
    
    public var pnpLikeDtmiCommands: PnPLikeDtmiCommands?
    private var pnpLConfiguration: [PnPLConfiguration]?
    private var allowedSensorsParameters = ["odr", "fs", "enable", "aop", "load_file", "ucf_status"]
    
    internal var documentSelector = DocumentSelector()
    
    init(_ pnpLikeDtmiCommands: PnPLikeDtmiCommands?) {
        self.pnpLikeDtmiCommands = pnpLikeDtmiCommands
        super.init(nibName: "HighSpeedDataLog2ConfigurationViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startNotification()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        PnPLikeService().storePnPLCurrentDemo("")
        stopNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterForeground),
                                                       name: UIApplication.didEnterBackgroundNotification,
                                                       object: nil)
                
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActivity),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "HighSpeedDatalog2ConfigurationViewCell", bundle: nil), forCellReuseIdentifier: "highspeeddatalog2configurationviewcell")
    }
    
    private func reloadData() {
        self.tableView.reloadData()
    }
    
    // MARK: - Handle BLE Notification
    public func startNotification(){
        guard let pnpLikeDtmiCommands = pnpLikeDtmiCommands else { return }

        mPnPL = self.node.getFeatureOfType(BlueSTSDKFeaturePnPL.self) as? BlueSTSDKFeaturePnPL
        if let feature = mPnPL{
            feature.add(self)
            self.node.enableNotification(feature)
            mPnPL?.sendPnPLGetDeviceStatusCmd(dtmi: pnpLikeDtmiCommands)
        }
    }

    public func stopNotification(){
        if let feature = mPnPL{
            feature.remove(self)
            self.node.disableNotification(feature)
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    @objc func didEnterForeground() {
        mPnPL = self.node.getFeatureOfType(BlueSTSDKFeaturePnPL.self) as? BlueSTSDKFeaturePnPL
        if !(mPnPL==nil) && node.isEnableNotification(mPnPL!) {
            featureWasEnabled = true
            stopNotification()
        }else {
            featureWasEnabled = false;
        }
    }
        
    @objc func didBecomeActivity() {
        if(featureWasEnabled) {
            startNotification()
        }
    }
}

// MARK: - Handle TABLE View
extension HighSpeedDataLog2ConfigurationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Handle Expand or Hide Cell
        guard let cellVisibile = pnpLConfiguration?[indexPath.row].visibile else { return }
        
        if(cellVisibile){
            pnpLConfiguration?[indexPath.row].visibile = false
            self.reloadData()
        } else {
            pnpLConfiguration?[indexPath.row].visibile = true
            self.reloadData()
        }
    }
}

extension HighSpeedDataLog2ConfigurationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pnpLConfiguration?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highspeeddatalog2configurationviewcell", for: indexPath) as! HighSpeedDatalog2ConfigurationViewCell
        
        /**Cell still be selectable, but you won't see the background colour change**/
        cell.selectionStyle = .none
        
        /// Remove subview from detailedView
        cell.detailedStackView.removeAllSubviews()
        
        cell.icon.image = pnpLConfiguration?[indexPath.row].specificSensorOrGeneralType.icon
        cell.desc.text = self.pnpLConfiguration?[indexPath.row].displayName
        
        /// Set Name Sensor + Image
        if(pnpLConfiguration?[indexPath.row].specificSensorOrGeneralType.name == nil) {
            cell.title.text = self.pnpLConfiguration?[indexPath.row].displayName
            cell.desc.isHidden = true
        }else{
            cell.title.text = pnpLConfiguration?[indexPath.row].specificSensorOrGeneralType.name
            cell.desc.isHidden = false
        }
        
        /// Build Row Parameters
        var rows: [UIStackView] = []
        var i = 0
        
        pnpLConfiguration?[indexPath.row].parameters?.forEach{ param in
            rows.append(
                PnPLParameterRow.buildParameterRow(
                    cellIndex: indexPath.row,
                    paramIndex: i,
                    param: param,
                    target: self,
                    btnAction: #selector(enumBtnTapped(_:)),
                    textFieldAction: #selector(textFieldTapped(_:)),
                    switchAction: #selector(switchTapped(_:)),
                    btnSENDAction: #selector(sendButtonTapped(_:)),
                    btnLOADFILEAction: #selector(loadFileButtonTapped(_:)),
                    dismissKeyboard: #selector(dismissKeyboard)
                )
            )
            i+=1
        }
        
        /// Add to vertical subView and set in detailedView
        var verticalSV = UIStackView()
        verticalSV = UIStackView.getVerticalStackView(withSpacing: 8, views: rows)

        cell.detailedStackView.addArrangedSubview(verticalSV)
        
        /// Hide or Expand Cell
        guard let detailCellVisible = pnpLConfiguration?[indexPath.row].visibile else { return cell }
        cell.detailedStackView.isHidden = !detailCellVisible
        
        
        
        return cell
    }
}

// MARK: - Handle UI elements tapped
extension HighSpeedDataLog2ConfigurationViewController {
    
    /** Handle Switch tapping selection  */
    @objc
    private func switchTapped(_ customSwitch: PnPLCustomSwicth) {
        guard let cellIndex = customSwitch.cellIndex else { return }
        guard let paramIndex = customSwitch.paramIndex else { return }
        self.pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.currentValue = customSwitch.isOn
        
        let elementName: String? = pnpLConfiguration?[cellIndex].name
        let paramName: String? = pnpLConfiguration?[cellIndex].parameters?[paramIndex].name
        var objectName: String? = nil
        
        if(customSwitch.objectIndex != nil){
            objectName = pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.paramObj?[customSwitch.objectIndex!].name
        }
        
        mPnPL?.sendPnPLJSON(elementName: elementName, paramName: paramName, objectName: objectName, value: customSwitch.isOn)
        guard let elementName = elementName else { return }
        if(elementName.contains("ism330dhcx")){
            self.mPnPL?.sendPnPLGetDeviceStatusCmd(dtmi: self.pnpLikeDtmiCommands)
        }
    }
    
    /** Handle tapping ENUM button selection  */
    @objc
    private func enumBtnTapped(_ enumCustomBtn: PnPLCustomButton) {
        var elementName: String? = nil
        if(enumCustomBtn.cellIndex != nil){
            elementName = pnpLConfiguration?[enumCustomBtn.cellIndex!].name
        }
        showEnumsChoice(elementName: elementName, enumCustomBtn: enumCustomBtn, enumValues: enumCustomBtn.param?.detail?.enumValues)
    }
    
    /** Modifiy current value by selection of Enum Value  */
    private func showEnumsChoice(elementName: String?, enumCustomBtn: PnPLCustomButton, enumValues: [Int : String]?) {
        var actions: [UIAlertAction] = []
        
        if(enumValues != nil && enumValues != [:]){
            for i in 0...(enumValues?.count ?? 1) - 1{
                actions.append(UIAlertAction.genericButton(enumValues?[i] ?? " ") { [weak self] _ in
                    guard let cellIndex = enumCustomBtn.cellIndex else { return }
                    guard let paramIndex = enumCustomBtn.paramIndex else { return }
                    
                    let elementName: String? = self?.pnpLConfiguration?[cellIndex].name
                    let paramName: String? = self?.pnpLConfiguration?[cellIndex].parameters?[paramIndex].name
                    
                    guard let enumValues = enumValues else { return }
                    self?.pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.currentValue = enumValues.findKey(forValue : enumValues[i]!)
                    self?.reloadData()
                    
                    self?.mPnPL?.sendPnPLJSON(elementName: elementName, paramName: paramName, objectName: nil, value: enumValues.findKey(forValue : enumValues[i]!) as Any)
                    if(elementName != nil){
                        self?.mPnPL?.sendPnPLGetDeviceStatusCmd(dtmi: self?.pnpLikeDtmiCommands)
                    }
                })
            }
            
            actions.append(UIAlertAction.cancelButton())
            
            UIAlertController.presentActionSheet(from: self, title: "Select Value".localizedFromGUI, message: nil, actions: actions)
        }
    }
    
    
    /** Handle insert new value in TextField  - ONLY DISMISS KEYBOARD */
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /** Handle insert new value in TextField  */
    @objc
    private func textFieldTapped(_ customTextField: PnPLCustomTextField) {
        if(customTextField.cellIndex != nil || customTextField.paramIndex != nil){
            guard let cellIndex = customTextField.cellIndex else { return }
            guard let paramIndex = customTextField.paramIndex else { return }
            
            let elementName: String? = pnpLConfiguration?[cellIndex].name
            let paramName: String? = pnpLConfiguration?[cellIndex].parameters?[paramIndex].name
            guard let primitiveType = pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.primitiveType else { return }
            
            var objectName: String? = nil
            
            if(customTextField.objectIndex == nil){
                self.pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.currentValue = customTextField.text
            } else {
                guard let objIndex = customTextField.objectIndex else { return }
                objectName = pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.paramObj?[customTextField.objectIndex!].name
                self.pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.paramObj?[objIndex].currentValue = customTextField.text
            }
            
            guard let value = customTextField.text else { return }
            var v: Any
            
            if(primitiveType.isPrimitiveTypeInteger){
                guard value.isInteger else { view.makeToast("Invalid Input. Required Integer value."); return }
                v = Int(value)!
            } else if(primitiveType.isPrimitiveTypeFloat){
                guard value.isFloat else { view.makeToast("Invalid Input. Required Float value."); return }
                v = Float(value)!
            } else if(primitiveType.isPrimitiveTypeDouble){
                guard value.isDouble else { view.makeToast("Invalid Input. Required Double value."); return }
                v = Double(value)!
            } else {
                v = String(value)
            }
            
            mPnPL?.sendPnPLJSON(elementName: elementName, paramName: paramName, objectName: objectName, value: v)
        }
        customTextField.resignFirstResponder()
    }
    
    /** Handle Switch tapping selection  */
    @objc
    private func sendButtonTapped(_ customSENDButton: PnPLSENDCustomButton) {
        guard let cellIndex = customSENDButton.cellIndex else { return }
        guard let paramIndex = customSENDButton.paramIndex else { return }
        
        let elementName: String? = self.pnpLConfiguration?[cellIndex].name
        let paramName: String? = self.pnpLConfiguration?[cellIndex].parameters?[paramIndex].name
        let requestName: String? = self.pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.requestName
        var objectName: String? = nil
        
        if(customSENDButton.objectIndex != nil){
            objectName = pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.paramObj?[customSENDButton.objectIndex!].name
        }
        
        var v: Any? = nil
        
        if(customSENDButton.enumValues != nil){
            guard let enumValues = customSENDButton.enumValues else { return }
            let key = enumValues.findKey(forValue: customSENDButton.value?[0].text ?? " ")
            self.mPnPL?.sendPnPLCommandJSON(elementName: elementName, paramName: paramName, requestName: requestName, objectName: objectName, value: key)
        } else {
            if(customSENDButton.value == nil){
                self.mPnPL?.sendPnPLCommandJSON(elementName: elementName, paramName: paramName, requestName: requestName, objectName: objectName, value: v)
            } else if (customSENDButton.value?.count == 1){
                v = customSENDButton.value?[0].text
                self.mPnPL?.sendPnPLCommandJSON(elementName: elementName, paramName: paramName, requestName: requestName, objectName: objectName, value: v)
            } else {
                guard let textFields = customSENDButton.value else { return }
                var objectsName: [String]? = []
                var objectsValues: [Any]? = []
                for i in 0...(textFields.count) - 1{
                    objectsName?.append(pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.paramObj?[i].name ?? " ")
                    objectsValues?.append(customSENDButton.value?[i].text as Any)
                }
                self.mPnPL?.sendPnPLCommandObjectJSON(elementName: elementName, paramName: paramName, requestName: requestName, objectsName: objectsName, values: objectsValues)
            }
        }
    }
    
    /** Handle Load File tapping selection  */
    @objc
    private func loadFileButtonTapped(_ customUploadFileButton: PnPLUploadFileCustomButton) {
        guard let cellIndex = customUploadFileButton.cellIndex else { return }
        guard let paramIndex = customUploadFileButton.paramIndex else { return }
        
        let elementName: String? = self.pnpLConfiguration?[cellIndex].name
        let paramName: String? = self.pnpLConfiguration?[cellIndex].parameters?[paramIndex].name
        let requestName: String? = self.pnpLConfiguration?[cellIndex].parameters?[paramIndex].detail?.requestName
        let objectsName: [String]? = customUploadFileButton.paramsName

        var values: [Any]? = []
        
        documentSelector.selectFile(from: self) { [weak self] url in
            DispatchQueue.main.async {
                if let value = try? String(contentsOf: url) {
                    print("MLC Size: \(value.count)")
                    print("MLC Value: \(value)")
                    //values?.append(value.count)
                    //values?.append(value)
                    
                    let mlcStr = self?.getUcfStringValue(ucfContent: value)
                    values?.append(mlcStr as Any)
                    values?.append(value.count)
                    
                    self?.mPnPL?.sendPnPLCommandObjectJSON(elementName: elementName, paramName: paramName, requestName: requestName, objectsName: objectsName, values: values)
                    self?.tableView.reloadData()
                    self?.mPnPL?.sendPnPLGetDeviceStatusCmd(dtmi: self?.pnpLikeDtmiCommands)
                }
            }
        }
    }
    
    private func getUcfStringValue(ucfContent: String) -> String {
        var contentFiltered = String(ucfContent.filter { !" \r\n".contains($0) })
        if let acRange = contentFiltered.range(of: "Ac") {
            contentFiltered.removeSubrange(contentFiltered.startIndex..<acRange.upperBound)
        }
        return contentFiltered.replacingOccurrences(of: "Ac", with: "")
    }
}


// MARK: - Handle BLE PnPLike Feature
extension HighSpeedDataLog2ConfigurationViewController: BlueSTSDKFeatureLogDelegate {
    func feature(_ feature: BlueSTSDKFeature, rawData raw: Data, sample: BlueSTSDKFeatureSample) {
        //debugPrint("Log Feature: \(feature), rawData: \(raw), sample: \(sample)")
    }
}

extension HighSpeedDataLog2ConfigurationViewController: BlueSTSDKFeatureDelegate {
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        //debugPrint("Feature: \(feature), sample: \(sample)")
        
        DispatchQueue.main.async {
            if let sample = sample as? PnPLSample {
                var filteredSensorsConfiguration = sample.pnpLConfiguration?.filter { $0.specificSensorOrGeneralType != .Unknown }
                
                var filteredParameters: [PnPLConfigurationParameter]?
                
                for i in 0..<(filteredSensorsConfiguration?.count ?? 0) {
                    filteredParameters = filteredSensorsConfiguration?[i].parameters?.filter { self.allowedSensorsParameters.contains($0.name ?? "") }
                    filteredSensorsConfiguration?[i].parameters = filteredParameters
                }
                
                self.pnpLConfiguration = filteredSensorsConfiguration
                
                self.reloadData()
            }
        }
    }
}
