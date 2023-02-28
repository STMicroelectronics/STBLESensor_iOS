//
//  HighSpeedDataLog2TagViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//


import UIKit
import BlueSTSDK
import BlueSTSDK_Gui

enum HSD2LogStatus {
    case idle
    case logging
}

class HighSpeedDataLog2TagViewController: BlueMSDemoTabViewController {
    
    private var hsd2LogStatus: HSD2LogStatus = .idle
    
    private static let PNPL_LOG_CONTROLLER = "log_controller"
    private static let PNPL_LOG_CONTROLLER_PARAM_SD_MOUNTED = "sd_mounted"
    private static let PNPL_LOG_CONTROLLER_PARAM_SET_TIME = "set_time"
    private static let PNPL_LOG_CONTROLLER_PARAM_REQUEST_DATE_TIME = "datetime"
    
    private static let PNPL_TAGS_INFO = "tags_info"
    private static let PNPL_TAGS_INFO_PARAM_DETAIL_LABEL = "label"
    private static let PNPL_TAGS_INFO_PARAM_DETAIL_ENABLED = "enabled"
    private static let PNPL_TAGS_INFO_PARAM_DETAIL_STATUS = "status"
    
    private static let PNPL_ACQUISITION_INFO = "acquisition_info"
    private static let PNPL_ACQUISITION_INFO_PARAM_NAME = "name"
    private static let PNPL_ACQUISITION_INFO_PARAM_DESCRIPTION = "description"
    
    private static let PNPL_START_LOG_PARAM = "start_log"
    private static let PNPL_START_LOG_PARAM_REQUEST_INTERFACE = "interface"
    
    private static let PNPL_STOP_LOG_PARAM = "stop_log"
    
    @IBOutlet weak var acquisitionNameTF: UITextField!
    @IBOutlet weak var acquisitionDescriptionTF: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    private var pnpLikeDtmiCommands: PnPLikeDtmiCommands?
    private var hsd2tags: [HSD2Tag] = []
    
    private var mPnPL: BlueSTSDKFeaturePnPL?
    private var featureWasEnabled = false
    private var pnpLConfiguration: [PnPLConfiguration]?
    
    private var sdCardMounted: Bool = false
    
    @IBAction func selectAllSwitch(_ sender: UISwitch) {
        for i in 0..<hsd2tags.count {
            hsd2tags[i].enabled = sender.isOn
        }
        reloadData()
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        if(startButton.currentTitle == "START") {
            startButton.setTitle("STOP", for: .normal)
            hsd2LogStatus = .logging
            
            /// Send ACQUISITION INFO - NAME
            mPnPL?.sendPnPLJSON(
                elementName: HighSpeedDataLog2TagViewController.PNPL_ACQUISITION_INFO,
                paramName: HighSpeedDataLog2TagViewController.PNPL_ACQUISITION_INFO_PARAM_NAME,
                objectName: nil,
                value: acquisitionNameTF.text ?? ""
            )
            
            /// Send ACQUISITION INFO - DESCRIPTION
            mPnPL?.sendPnPLJSON(
                elementName: HighSpeedDataLog2TagViewController.PNPL_ACQUISITION_INFO,
                paramName: HighSpeedDataLog2TagViewController.PNPL_ACQUISITION_INFO_PARAM_DESCRIPTION,
                objectName: nil,
                value: acquisitionDescriptionTF.text ?? "")
            
            /// Send START LOG
            mPnPL?.sendPnPLCommandJSON(
                elementName: HighSpeedDataLog2TagViewController.PNPL_LOG_CONTROLLER,
                paramName: HighSpeedDataLog2TagViewController.PNPL_START_LOG_PARAM,
                requestName: HighSpeedDataLog2TagViewController.PNPL_START_LOG_PARAM_REQUEST_INTERFACE,
                objectName: nil,
                value: 0
            )
            
            for i in 0..<hsd2tags.count { hsd2tags[i].enabled = false }
            reloadData()
        } else {
            startButton.setTitle("START", for: .normal)
            hsd2LogStatus = .idle
            
            /// Send STOP LOG
            mPnPL?.sendPnPLCommandJSON(
                elementName: HighSpeedDataLog2TagViewController.PNPL_LOG_CONTROLLER,
                paramName: HighSpeedDataLog2TagViewController.PNPL_STOP_LOG_PARAM,
                requestName: nil,
                objectName: nil,
                value: nil
            )
            
            for i in 0..<hsd2tags.count { hsd2tags[i].enabled = true }
            reloadData()
        }
    }
    
    init(_ pnpLikeDtmiCommands: PnPLikeDtmiCommands?) {
        self.pnpLikeDtmiCommands = pnpLikeDtmiCommands
        super.init(nibName: "HighSpeedDataLog2TagViewController", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startNotification()
        setDateTime()
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
        
        acquisitionNameTF.addTarget(target, action: #selector(dismissKeyboard), for: .editingDidEndOnExit)
        acquisitionDescriptionTF.addTarget(target, action: #selector(dismissKeyboard), for: .editingDidEndOnExit)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "HighSpeedDataLog2TagViewCell", bundle: nil), forCellReuseIdentifier: "highspeeddatalog2tagviewcell")
    }
    
    
    private func reloadData() {
        self.tableView.reloadData()
    }
    
    @objc
    private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    private func setDateTime(){
        let date = Date()
        let formattedDate = date.getFormattedDate(format: "yyyyMMdd_HH_mm_ss")
        mPnPL?.sendPnPLCommandJSON(
            elementName: HighSpeedDataLog2TagViewController.PNPL_LOG_CONTROLLER,
            paramName: HighSpeedDataLog2TagViewController.PNPL_LOG_CONTROLLER_PARAM_SET_TIME,
            requestName: HighSpeedDataLog2TagViewController.PNPL_LOG_CONTROLLER_PARAM_REQUEST_DATE_TIME,
            objectName: nil,
            value: formattedDate
        )
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
    
    func setStartButtonBasedOnSDCardStatus(isMounted: Bool){
        if(isMounted == false){
            startButton.isUserInteractionEnabled = false
            startButton.isEnabled = false
            startButton.setTitle("SD CARD MISSING", for: .normal)
        } else {
            startButton.isUserInteractionEnabled = true
            startButton.isEnabled = true
            startButton.setTitle("START", for: .normal)
        }
    }
}

extension HighSpeedDataLog2TagViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("you tapped me")
    }
}

extension HighSpeedDataLog2TagViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hsd2tags.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "highspeeddatalog2tagviewcell", for: indexPath) as! HighSpeedDataLog2TagViewCell
        
        /**Cell still be selectable, but you won't see the background colour change**/
        cell.selectionStyle = .none
        
        cell.tagName.text = hsd2tags[indexPath.row].label
        cell.tagSwitch.isOn = hsd2tags[indexPath.row].enabled
        
        cell.editTagName.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        cell.editTagName.tag = indexPath.row
        
        cell.tagSwitch.addTarget(self, action: #selector(switchTapped), for: .valueChanged)
        cell.tagSwitch.tag = indexPath.row
        
        return cell
    }
    
    @objc func editButtonTapped(sender: UIButton!) {
        var mTextField: UITextField?
        UIAlertController.presentTextFieldAlert(
            from: self,
            title: "Change Tag Label",
            confirmButton: UIAlertAction.genericButton("Apply", { [weak self] _ in
                if let text = mTextField?.text, !text.isEmpty {
                    self?.hsd2tags[sender.tag].label = text
                    self?.mPnPL?.sendPnPLJSON(
                        elementName: HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO,
                        paramName: self?.hsd2tags[sender.tag].id,
                        objectName: HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO_PARAM_DETAIL_LABEL,
                        value: text)
                    self?.reloadData()
                }
            }),
            cancelButton: UIAlertAction.cancelButton()) { textField, controller in
            mTextField = textField
        }
    }
    
    @objc func switchTapped(sender: UISwitch!) {
        self.hsd2tags[sender.tag].enabled = sender.isOn
        if(hsd2LogStatus == .idle) {
            mPnPL?.sendPnPLJSON(
                elementName: HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO,
                paramName: self.hsd2tags[sender.tag].id,
                objectName: HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO_PARAM_DETAIL_ENABLED,
                value: sender.isOn
            )
        } else {
            mPnPL?.sendPnPLJSON(
                elementName: HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO,
                paramName: self.hsd2tags[sender.tag].id,
                objectName: HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO_PARAM_DETAIL_STATUS,
                value: sender.isOn
            )
        }
    }
}

// MARK: - Handle BLE PnPLike Feature
extension HighSpeedDataLog2TagViewController: BlueSTSDKFeatureLogDelegate {
    func feature(_ feature: BlueSTSDKFeature, rawData raw: Data, sample: BlueSTSDKFeatureSample) {
        //debugPrint("Log Feature: \(feature), rawData: \(raw), sample: \(sample)")
    }
}

extension HighSpeedDataLog2TagViewController: BlueSTSDKFeatureDelegate {
    func didUpdate(_ feature: BlueSTSDKFeature, sample: BlueSTSDKFeatureSample) {
        DispatchQueue.main.async {
            if let sample = sample as? PnPLSample {
                
                let tagsInfo = sample.pnpLConfiguration?.filter { $0.name == HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO }
                let logController = sample.pnpLConfiguration?.filter { $0.name == HighSpeedDataLog2TagViewController.PNPL_LOG_CONTROLLER }
                
                var tagIteration = 0
                
                let totalParam = tagsInfo?[0].parameters?.count
                tagsInfo?[0].parameters?.forEach { param in
                    if(tagIteration==0){
                        tagIteration += 1
                    } else {
                        var currentHSD2Tag = HSD2Tag(id: param.name, name: "", enabled: false)
                        param.detail?.paramObj?.forEach { paramDetail in
                            if(paramDetail.name == HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO_PARAM_DETAIL_LABEL) {
                                currentHSD2Tag.label = paramDetail.currentValue as? String ?? ""
                            } else if (paramDetail.name == HighSpeedDataLog2TagViewController.PNPL_TAGS_INFO_PARAM_DETAIL_ENABLED) {
                                currentHSD2Tag.enabled = paramDetail.currentValue as? Bool ?? false
                            }
                        }
                        if(self.hsd2tags.count == (totalParam ?? 1) - 1){
                            print("Max Param Count")
                        } else {
                            self.hsd2tags.append(currentHSD2Tag)
                        }
                    }
                }
                
                logController?[0].parameters?.forEach { param in
                    if(param.name == HighSpeedDataLog2TagViewController.PNPL_LOG_CONTROLLER_PARAM_SD_MOUNTED) {
                        self.sdCardMounted = param.detail?.currentValue as? Bool ?? false
                        self.setStartButtonBasedOnSDCardStatus(isMounted: self.sdCardMounted)
                    }
                }
                
                self.pnpLConfiguration = sample.pnpLConfiguration
                
                self.tableView.reloadData()
            }
        }
    }
}

public struct HSD2Tag {
    public let id: String?
    public var label: String
    public var enabled: Bool
    
    public init(id: String?, name: String, enabled: Bool){
        self.id = id
        self.label = name
        self.enabled = enabled
    }
    
    public enum HSD2Type {
        case software
        case hardware
    }
}

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
